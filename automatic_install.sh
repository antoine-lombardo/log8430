#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root using sudo ./automatic_install.sh"
  exit
fi

rm -rf log8430
git clone https://github.com/antoine-lombardo/log8430.git
cd log8430/auto_script
chmod +x auto_script.sh
./auto_script.sh
