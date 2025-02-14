#!/usr/bin/env python3

import yaml, sys

if len(sys.argv) != 2:
    print("Wrong arguments");
    sys.exit(1)

images_file = sys.argv[1]

with open(images_file, 'r') as stream:
    configuration = yaml.safe_load(stream)

for image in configuration['baseimages']:
    if 'envfile' in image:
        image_name = image['image']
        for key, value in (l.split('=') for l in open(image['envfile']) if l.strip() != ''):
            image_name = image_name.replace('$' + key.strip(), value.strip())
        print(image_name)
    else:
        print(image['image'])

