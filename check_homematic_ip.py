#!/usr/bin/env python3
import sys

import homematicip
from homematicip.home import Home

_config = homematicip.find_and_load_config_file()

if _config is None:
    print("Could not find configuration file. Script will exit")
    sys.exit(3)

home = Home()
home.set_auth_token(_config.auth_token)
home.init(_config.access_point)

if not home.get_current_state():
    sys.exit(3)

problems = False
for g in home.groups:
    if g.groupType == 'META':
        for d in g.devices:
            if d.lowBat or d.unreach:
                print("Room {}, device {}: lowBat={} unreach={}".format(g.label, d.label, d.lowBat, d.unreach))

if problems:
    sys.exit(2)

print("Everything fine")

