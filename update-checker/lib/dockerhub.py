#!/usr/bin/python3

import requests, re, sys
from distutils.version import LooseVersion

url = 'https://registry.hub.docker.com/v1/repositories/' + sys.argv[1] + '/tags'

tags = requests.get(url).json()

regex = re.compile('^[0-9]+\.[0-9]+\.[0-9]+$')
names = map(lambda x: x['name'], tags)
filtered_names = filter(regex.match, names)
if len(sys.argv) > 2:
    filtered_names = [n for n in filtered_names if n.startswith(sys.argv[2])]

versions = [LooseVersion(v) for v in filtered_names]
versions.sort()
print(versions[-1].vstring)

