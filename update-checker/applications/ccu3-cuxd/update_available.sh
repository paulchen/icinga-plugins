#!/bin/bash
wget 'https://homematic-forum.de/forum/viewtopic.php?f=37&t=15298' -q -O - | grep '<title>' |sed -e 's/^.*CUxD //;s/ .*//'

