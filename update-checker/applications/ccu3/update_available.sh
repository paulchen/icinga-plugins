#!/bin/bash
wget https://homematic-ip.com/de/produkt/smart-home-zentrale-ccu3/downloads -q -O - | grep 'Aktuelle Version' | sed -e "s/.*Aktuelle Version //;s/<.*//"

