#!/bin/bash

wget -q -O - https://www.phpmyadmin.net/downloads/|grep '<h2>phpMyAdmin'|sed -e 's/^.* //;s/<.*$//'|sort --version-sort -r|head -n 1

