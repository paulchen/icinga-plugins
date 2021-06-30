#!/usr/bin/env python3

import sys, os, argparse
from rocketchat_API.rocketchat import RocketChat

parser = argparse.ArgumentParser(description='Checks a Rocket.Chat instance for proper operation')
parser.add_argument('-u', required=True, help='Login username')
parser.add_argument('-p', required=True, help='Login password')
parser.add_argument('-a', required=False, help='Web address of Rocket.Chat instance', default='http://localhost:3000')
args = parser.parse_args()

rocketUser = args.u
rocketPass = args.p
rocketServer = args.a

rocketApi = RocketChat(rocketUser, rocketPass, server_url=rocketServer)
response = rocketApi.statistics()

if response.json()['success']:
    print('OK')
else:
    print('CRITICAL - Error when calling REST API')
    sys.exit(2)

