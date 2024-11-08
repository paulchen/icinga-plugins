#!/usr/bin/env python3

from pathlib import Path
import subprocess, yaml, time, functools, sys

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
    configuration = yaml.safe_load(stream)

print(f'Data read from configuration file: {configuration}')

error = False
to_update = set()
for script in configuration['checkscripts']:
    if len(sys.argv) == 2 and sys.argv[1] == '-f':
        for application in script['applications']:
            print(f'Argument -f given, therefore adding {application} to the list of applications that need to be updated')
            to_update.add(application)
    else:
        command = script['command']
        # https://stackoverflow.com/a/28567888/8569278
        if all(x in to_update for x in script['applications']):
            print(f'Not running {command} as all applications have already determined to need an update')
            continue

        print(f'Executing {command}')
        proc = subprocess.run(command, capture_output=True, shell=False)
        print(proc.stdout)
        if proc.returncode == 2:
            print(f'Image is out of date')
            for application in script['applications']:
                print(f'Adding {application} to the list of applications that need to be updated')
                to_update.add(application)
        elif proc.returncode > 0:
            print(f'Error running check script')
            error = True
        else:
            print(f'Image is up to date')

if error:
    print('At least one check script did not complete successfully')
    sys.exit(1)

error = False
for image in configuration['baseimages']:
    if len(sys.argv) == 2 and sys.argv[1] == '-f':
        for application in image['applications']:
            print(f'Argument -f given, therefore adding {application} to the list of applications that need to be updated')
            to_update.add(application)
    else:
        # https://stackoverflow.com/a/28567888/8569278
        if all(x in to_update for x in image['applications']):
            print(f"Not checking base image {image['image']} as all applications have already determined to need an update")
            continue

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
            error = True
        else:
            print(f"Base image {image['image']} is up to date")

if error:
    print('At least one base image could not be checked')
    sys.exit(1)

print(f'Applications to update: {to_update}')

for application in to_update:
    print(f'Rebuilding {application}')

    update_script = Path(__file__).resolve().parent / 'applications' / f'update-{application}.sh'
    if update_script.exists():
        command = [update_script]
        command.extend(sys.argv[1:])
        returncode = subprocess.call(command)
        if returncode > 0:
            print(f'Error rebuilding {application}')
            error = True
        else:
            print(f'Rebuilding {application} finished')
    else:
        print(f'{application} cannot be rebuilt as script {update_script} cannot be found')

if error:
    print('At least one error occurred, not running check_tags.sh')
else:
    print('Running check_tags.sh')
    # https://stackoverflow.com/questions/10177587/redirecting-the-output-of-shell-script-executing-through-python
    command = [check_tags_script, images_file]
    with open(status_file, 'w') as output:
        returncode = subprocess.call(command, stdout=output, shell=False)
        if returncode > 0:
            print('Error running check_tags.sh')
            error = True

end_time = time.perf_counter()
total_time = end_time - start_time

print('Elapsed time: %s seconds' % (round(total_time, 2)))

if error:
    print('Execution completed with errors')
    sys.exit(1)
else:
    print('Execution successfully completed without any errors')

