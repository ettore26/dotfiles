#!/bin/bash

nmcli -f IN-USE,SSID,BARS dev wifi | awk '/*/ {print $2 " " $3}'
