#!/usr/bin/python3

import requests, re, sys
from distutils.version import LooseVersion

namespace = sys.argv[1]
repository = sys.argv[2]

url = f'https://registry.hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags?page_size=20'

response = requests.get(url)
if response.status_code >= 300:
    print(f"Error fetching data from {url}; status code: {response.status_code}; contents:\n{response.text}")
    sys.exit(1)

tags = response.json()

regex = re.compile('^[0-9]+\.[0-9]+\.[0-9]+$')
names = map(lambda x: x['name'], tags['results'])
filtered_names = filter(regex.match, names)
if len(sys.argv) > 3:
    filtered_names = [n for n in filtered_names if n.startswith(sys.argv[3])]

versions = [LooseVersion(v) for v in filtered_names]
versions.sort()
print(versions[-1].vstring)

