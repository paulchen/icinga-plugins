#!/bin/bash

docker pull php:8.2-apache-bookworm

sudo -u paulchen /var/www/huntu-dev/docker/build.sh huntu-dev

systemctl restart huntu-dev

sudo -u paulchen /var/www/huntu/docker/build.sh huntu

systemctl restart huntu

