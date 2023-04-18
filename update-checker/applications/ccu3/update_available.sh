#!/bin/bash
wget https://homematic-ip.com/de/downloads -q -O - | grep 'Firmware Smart Home Zentrale CCU3' | sed -e 's/<[^>]*>//g' | sed -e 's/^.*, //;s/Aktuelle Version //' | head -n 1

