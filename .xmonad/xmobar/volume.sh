#!/bin/bash

pacmd list-sinks |  awk '/^\svolume:/ {print $5}'
