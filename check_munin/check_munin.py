#!/usr/bin/env python3

from time import time
from subprocess import Popen, PIPE
from sys import exit

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


ignorelist = {'*': ['sensor17']}

period_start = time() - 600

p = Popen(['ssh', '-p22223', 'munin-async@localhost', '/usr/share/munin/munin-async', '--spoolfetch'], stdin = PIPE, stdout = PIPE)
input = 'spoolfetch %s' % period_start
result = p.communicate(input.encode())

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

