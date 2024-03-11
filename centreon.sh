#!/bin/bash

# Download file to execute for central Centreon
curl -L https://raw.githubusercontent.com/centreon/centreon/23.10.x/centreon/unattended.sh --output /tmp/unattended.sh

# Execute file and save last 10 lines in file.txt
bash /tmp/unattended.sh install -t central -v 23.10 -r stable -s -p 'Password123*' -l DEBUG  2>&1 |tee -a /tmp/unattended-$(date +"%m-%d-%Y-%H%M%S").log | tail -10 > file.txt
