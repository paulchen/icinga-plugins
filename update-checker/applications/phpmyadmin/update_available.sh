#!/bin/bash

wget -q -O - "https://api.github.com/repos/phpmyadmin/phpmyadmin/releases/latest" --timeout=15|grep -Po '"name": "\K.*?(?=")'

