#!/usr/bin/python3

import argparse, urllib3, certifi, sys, json
from http.client import responses

parser = argparse.ArgumentParser(description='Checks for open notifications for a user on a Nextcloud instance')
parser.add_argument('-u', required=True, help='Login username')
parser.add_argument('-p', required=True, help='Login password')
parser.add_argument('-a', required=True, help='Web address of Nextcloud instance')
args = parser.parse_args()

username = args.u
password = args.p
url = args.a

http = urllib3.PoolManager(cert_reqs='CERT_REQUIRED', ca_certs=certifi.where())

headers = urllib3.util.make_headers(basic_auth=username + ":" + password)
headers['Accept'] = 'application/json'
headers['OCS-APIRequest'] = 'true'

endpoint_url = url + '/ocs/v2.php/apps/notifications/api/v2/notifications'

response = http.request('GET', endpoint_url, headers=headers)
status = response.status
if status != 200:
    print('UNKNOWN: HTTP error - %s %s' % (status, responses[status]))
    sys.exit(3)

json = json.loads(response.data.decode('utf-8'))
data = json['ocs']['data']
if len(data) > 0:
    print('WARNING: %s notifications' % (len(data), ))
    sys.exit(1)

print('OK: No notifications')

