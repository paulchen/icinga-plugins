#!/usr/bin/python3

import requests, re, sys, platform
from distutils.version import LooseVersion

namespace = sys.argv[1]
repository = sys.argv[2]

url = f'https://registry.hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags?page_size=50'


def has_image(node, os, arch, variant):
    for image in node['images']:
        if image['os'] == os and image['architecture'] == arch and image['variant'] == variant:
            return True
    return False


if platform.system() == 'Linux':
    os = 'linux'
else:
    print(f"Unknown platform {platform.system()}")
    sys.exit(1)
if platform.machine() == 'x86_64':
    arch = 'amd64'
    variant = None
else:
    print(f"Unknown machine {platform.machine()}")

if len(sys.argv) == 3:
    url_latest = url + '&name=latest'
    response = requests.get(url_latest)
    if response.status_code >= 300:
        print(f"Error fetching data from {url}; status code: {response.status_code}; contents:\n{response.text}")
        sys.exit(1)

    tags = response.json()
    latest_tags = [x for x in tags['results'] if x['name'] == 'latest' and has_image(x, os, arch, variant)]
    if len(latest_tags) == 0:
        latest_tag = None
    else:
        latest_tag = latest_tags[0]['digest']
else:
    url = url + '&name=' + sys.argv[3]
    latest_tag = None


while True:
    response = requests.get(url)
    if response.status_code >= 300:
        print(f"Error fetching data from {url}; status code: {response.status_code}; contents:\n{response.text}")
        sys.exit(1)

    tags = response.json()
    if len(tags) == 0:
        print('No tags found in response from API')
        sys.exit(1)

    if latest_tag != None:
        filtered_tags = [x for x in tags['results'] if 'digest' in x and x['digest'] == latest_tag and x['name'] != 'latest' and not x['name'].startswith('sha-') and has_image(x, os, arch, variant)]
        if len(filtered_tags) == 1:
            print(filtered_tags[0]['name'])
            break

        url = tags['next']
        continue

    names = [x['name'] for x in tags['results'] if has_image(x, os, arch, variant)]

    regex = re.compile('^[0-9]+\.[0-9]+\.[0-9]+$')
    if len(sys.argv) > 3:
        if len(sys.argv) > 4:
            regex = re.compile(sys.argv[4])
        filtered_names = filter(regex.match, names)
        filtered_names = [n for n in filtered_names if n.startswith(sys.argv[3]) or n.endswith(sys.argv[3])]
    else:
        filtered_names = filter(regex.match, names)

    versions = [LooseVersion(v) for v in filtered_names]
    if len(versions) > 0:
        versions.sort()
        print(versions[-1].vstring)
        break

    url = tags['next']

