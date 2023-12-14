#!/usr/bin/python3

# don't run this script too often as every request to the server info including
# app updates will execute a call to apps.nextcloud.com

import argparse, sys, json, requests

parser = argparse.ArgumentParser(description='Checks for available updates on a Nextcloud instance')
parser.add_argument('-u', required=True, help='Login username')
parser.add_argument('-p', required=True, help='Login password')
parser.add_argument('-a', required=True, help='Web address of Nextcloud instance')
args = parser.parse_args()

username = args.u
password = args.p
url = args.a

# partly taken from https://github.com/mightyBroccoli/nextcloud-munin-py

# init request session with specific header and credentials
with requests.Session() as s:
    # read credentials from env
    s.auth = (username, password)

    # update header for json
    s.headers.update({'Accept': 'application/json'})

    # request the data
    try:
        r = s.get(url + '/ocs/v2.php/apps/serverinfo/api/v1/info?skipApps=false')
    except requests.exceptions.ConnectionError as e:
        print('UNKNOWN: unable to fetch status: %s' % e)
        sys.exit(3)

# if status code is successful continue
if r.status_code == 200:
    api_response = r.json()
#    print(api_response)
    num_updates_available = api_response['ocs']['data']['nextcloud']['system']['apps']['num_updates_available']
    if num_updates_available > 0:
        apps_with_updates = api_response['ocs']['data']['nextcloud']['system']['apps']['app_updates']
        app_list = ', '.join(apps_with_updates.keys())
        print('WARNING: %s updates available - %s' % (num_updates_available, app_list))
        sys.exit(1)

    print('OK: no updates available')
    sys.exit(0)

print('UNKNOWN: status code %s returned' % r.status_code)
sys.exit(3)

