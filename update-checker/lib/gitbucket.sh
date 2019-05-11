#!/bin/bash

git ls-remote "https://git.rueckgr.at/git/$1.git"|grep '\sHEAD$'|cut -d$'\t' -f 1

