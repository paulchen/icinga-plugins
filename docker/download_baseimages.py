#!/usr/bin/env python3

from pathlib import Path
import subprocess, yaml, time

start_time = time.perf_counter()

directory = Path(__file__).resolve().parent
images_file = Path(__file__).resolve().parent / 'images.yaml'

# https://stackoverflow.com/questions/1773805/how-can-i-parse-a-yaml-file-in-python
with open(images_file, 'r') as stream:
    images = yaml.safe_load(stream)

print(f'Data read from configuration file: {images}')

error = False
to_update = set()
for image in images:
    command = ['docker', 'pull', image['image']]
    print(f'Executing {command}')
    proc = subprocess.run(command, shell=False)
    if proc.returncode > 0:
        error = True
        print(f"Error pulling image {image['image']}")
    else:
        print(f"Base image {image['image']} successfully fetched")

end_time = time.perf_counter()
total_time = end_time - start_time

print('Elapsed time: %s seconds' % (round(total_time, 2)))

if error:
    print(f'Execution completed with errors')
    sys.exit(1)
else:
    print(f'Execution completed successfully')

