#!/usr/bin/env python3

from pathlib import Path
import subprocess, yaml, time, functools

# https://stackoverflow.com/questions/230751/how-can-i-flush-the-output-of-the-print-function
print = functools.partial(print, flush=True)

start_time = time.perf_counter()

directory = Path(__file__).resolve().parent
check_tags_script = Path(__file__).resolve().parent / 'check_tags.sh'
check_tag_script = Path(__file__).resolve().parent / 'check_tag.sh'
images_file = Path(__file__).resolve().parent / 'images.yaml'
status_file = Path(__file__).resolve().parent / 'status'

# https://stackoverflow.com/questions/1773805/how-can-i-parse-a-yaml-file-in-python
with open(images_file, 'r') as stream:
    images = yaml.safe_load(stream)

print(f'Data read from configuration file: {images}')

to_update = set()
for image in images:
    command = [check_tag_script, image['image']]
    print(f'Executing {command}')
    proc = subprocess.run(command, capture_output=True, shell=False)
    print(proc.stdout)
    if proc.returncode == 2:
        print(f"Base image {image['image']} found to be out of date")
        for application in image['applications']:
            print(f'Adding {application} to the list of applications that need to be updated')
            to_update.add(application)
    elif proc.returncode > 0:
        print(f"Error checking whether {image['image']} is up to date")
    else:
        print(f"Base image {image['image']} is up to date")

print(f'Applications to update: {to_update}')

for application in to_update:
    print(f'Rebuilding {application}')

    update_script = Path(__file__).resolve().parent / 'applications' / f'update-{application}.sh'
    if update_script.exists():
        subprocess.call([update_script])
        print(f'Rebuilding {application} finished')
    else:
        print(f'{application} cannot be rebuilt as script {update_script} cannot be found')

print(f'Running check_tags.sh')
# https://stackoverflow.com/questions/10177587/redirecting-the-output-of-shell-script-executing-through-python
command = [check_tags_script, images_file]
with open(status_file, 'w') as output:
    subprocess.call(command, stdout=output, shell=False)

end_time = time.perf_counter()
total_time = end_time - start_time

print('Elapsed time: %s seconds' % (round(total_time, 2)))

print(f'Execution completed')

