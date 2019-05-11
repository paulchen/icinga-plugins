#!/usr/bin/env python3

from time import time
from subprocess import Popen, PIPE
from sys import exit
from argparse import ArgumentParser, FileType


def is_ignored(ignorelist, graph, value):
    if '*' in ignorelist.keys():
        if value in ignorelist['*']:
            return True

        if '*' in ignorelist['*']:
            return True

    if graph in ignorelist.keys():
        if value in ignorelist[graph]:
            return True

        if '*' in ignorelist[graph]:
            return True

    return False


def parse_ignorelist(file):
    ignorelist = {}
    if file:
        for line in file:
            parts = line.strip().split('.')
            if len(parts) != 2:
                continue
            if not parts[0] in ignorelist:
                ignorelist[parts[0]] = []
            ignorelist[parts[0]].append(parts[1])

    return ignorelist


parser = ArgumentParser(description="Checks for munin plugins that don't return values", add_help=False)
parser.add_argument('--help', action='help', help='show this help message and exit')
parser.add_argument('-h', required=True, help='Host name where munin-asyncd is running')
parser.add_argument('-p', default='22', help='SSH port of the host specified by -h')
parser.add_argument('-i', type=FileType('r'), help='File name containing the ignore list')
args = parser.parse_args()

ignorelist = parse_ignorelist(args.i)

period_start = time() - 600

p = Popen(['ssh', '-p', args.p, args.h, '-l', 'munin-async', '/usr/share/munin/munin-async', '--spoolfetch'], stdin = PIPE, stdout = PIPE, stderr = PIPE)
input = 'spoolfetch %s' % period_start
result = p.communicate(input.encode())

if p.returncode:
    print('UNKNOWN - SSH returned error code %s' % p.returncode)
    exit(3)

graph_name = '<none>'
graphs_seen = {}
values_seen = {}

for line in result[0].decode('iso-8859-1').split('\n'):
    if line.startswith('#'):
        continue

    if len(line) < 2:
        continue

#    print(line)

    parts = line.split()
    if parts[0] == 'multigraph':
        graph_name = parts[1]
        graphs_seen[graph_name] = []
        values_seen[graph_name] = []
        continue

    if '.' in parts[0]:
        parts2 = parts[0].split('.')
        if parts2[1] == 'value':
            if parts2[0] not in values_seen:
#                print('Value seen: %s %s' % (graph_name, parts2[0]))
                values_seen[graph_name].append(parts2[0])
        else:
            if parts2[0] not in graphs_seen:
#                print('Graph seen: %s %s' % (graph_name, parts2[0]))
                graphs_seen[graph_name].append(parts2[0])

result = 0
for graph_name, graphs in graphs_seen.items():
    for graph in graphs:
        if graph not in values_seen[graph_name]:
            if not is_ignored(ignorelist, graph_name, graph):
                print('CRITICAL - No value for %s for graph %s ' % (graph, graph_name))
                result = 2

if result == 0:
    print('OK - All munin plugins return values')

exit(result)

