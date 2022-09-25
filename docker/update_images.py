#!/usr/bin/env python3

from pathlib import Path
import subprocess

directory = Path(__file__).resolve().parent
check_script = Path(__file__).resolve().parent / 'check_tags.sh'
images_file = Path(__file__).resolve().parent / 'images.yaml'
status_file = Path(__file__).resolve().parent / 'status'

# https://stackoverflow.com/questions/10177587/redirecting-the-output-of-shell-script-executing-through-python
command = [check_script, images_file]
with open(status_file, 'w') as output:
    subprocess.call(command, stdout=output, shell=False)

