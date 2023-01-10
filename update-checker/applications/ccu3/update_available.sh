#!/bin/bash
wget https://homematic-ip.com/de/produkt/smart-home-zentrale-ccu3/downloads -q -O - | grep 'Firmware Smart Home Zentrale CCU3' | sed -e 's/<[^>]*>//g' | sed -e 's/^.*, //' | head -n 1

