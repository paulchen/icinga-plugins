#!/bin/bash

wget -q -O - https://www.phpmyadmin.net/downloads/|grep '<h2>phpMyAdmin'|head -n 1 |sed -e 's/^.* //;s/<.*$//'

