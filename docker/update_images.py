#!/usr/bin/env python3

from pathlib import Path
import subprocess, yaml, time, sys, logging

logger = logging.getLogger()
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s %(message)s'))
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

start_time = time.perf_counter()

directory = Path(__file__).resolve().parent
check_tags_script = Path(__file__).resolve().parent / 'check_tags.sh'
check_tag_script = Path(__file__).resolve().parent / 'check_tag.sh'
images_file = Path(__file__).resolve().parent / 'images.yaml'
status_file = Path(__file__).resolve().parent / 'status'

# https://stackoverflow.com/questions/1773805/how-can-i-parse-a-yaml-file-in-python
with open(images_file, 'r') as stream:
    configuration = yaml.safe_load(stream)

logger.info('Data read from configuration file: %s', configuration)

error = False
to_update = set()
for script in configuration['checkscripts']:
    if len(sys.argv) == 2 and sys.argv[1] == '-f':
        for application in script['applications']:
            logger.info('Argument -f given, therefore adding %s to the list of applications that need to be updated', application)
            to_update.add(application)
    else:
        command = script['command']
        # https://stackoverflow.com/a/28567888/8569278
        if all(x in to_update for x in script['applications']):
            logger.info(f'Not running %s as all applications have already determined to need an update', command)
            continue

        logger.info('Executing %s', command)
        proc = subprocess.run(command, capture_output=True, shell=False)
        logger.info(proc.stdout)
        if proc.returncode == 2:
            logger.info('Image is out of date')
            for application in script['applications']:
                logger.info('Adding %s to the list of applications that need to be updated', application)
                to_update.add(application)
        elif proc.returncode > 0:
            logger.error('Error running check script')
            error = True
        else:
            logger.info('Image is up to date')

if error:
    logger.error('At least one check script did not complete successfully')
    sys.exit(1)

error = False
for image in configuration['baseimages']:
    if len(sys.argv) == 2 and sys.argv[1] == '-f':
        for application in image['applications']:
            logger.info('Argument -f given, therefore adding %s to the list of applications that need to be updated', application)
            to_update.add(application)
    else:
        if 'envfile' in image:
            image_name = image['image']
            for key, value in (l.split('=') for l in open(image['envfile']) if l.strip() != ''):
                image_name = image_name.replace('$' + key.strip(), value.strip())
        else:
            image_name = image['image']

        # https://stackoverflow.com/a/28567888/8569278
        if all(x in to_update for x in image['applications']):
            logger.info('Not checking base image %s as all applications have already determined to need an update', image_name)
            continue

        command = [check_tag_script, image_name]
        logger.info('Executing %s', command)
        proc = subprocess.run(command, capture_output=True, shell=False)
        logger.info(proc.stdout)
        if proc.returncode == 2:
            logger.info('Base image %s found to be out of date', image_name)
            for application in image['applications']:
                logger.info('Adding %s to the list of applications that need to be updated', application)
                to_update.add(application)
        elif proc.returncode > 0:
            logger.error('Error checking whether %s is up to date', image_name)
            error = True
        else:
            logger.info('Base image %s is up to date', image_name)

if error:
    logger.error('At least one base image could not be checked')
    sys.exit(1)

logger.info('Applications to update: %s', to_update)

for application in to_update:
    logger.info('Rebuilding %s', application)

    update_script = Path(__file__).resolve().parent / 'applications' / f'update-{application}.sh'
    if update_script.exists():
        command = [update_script]
        command.extend(sys.argv[1:])
        returncode = subprocess.call(command)
        if returncode > 0:
            logger.error('Error rebuilding %s', application)
            error = True
        else:
            logger.info('Rebuilding %s finished', application)
    else:
        logger.error('%s cannot be rebuilt as script %s cannot be found', application, update_script)

if error:
    logger.error('At least one error occurred, not running check_tags.sh')
else:
    logger.info('Running check_tags.sh')
    # https://stackoverflow.com/questions/10177587/redirecting-the-output-of-shell-script-executing-through-python
    command = [check_tags_script, images_file]
    with open(status_file, 'w') as output:
        returncode = subprocess.call(command, stdout=output, shell=False)
        if returncode > 0:
            logger.error('Error running check_tags.sh')
            error = True

end_time = time.perf_counter()
total_time = end_time - start_time

logger.info('Elapsed time: %s seconds', (round(total_time, 2)))

if error:
    logger.error('Execution completed with errors')
    sys.exit(1)
else:
    logger.info('Execution successfully completed without any errors')

