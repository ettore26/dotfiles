#! /bin/bash

git branch --merged | grep -v "main\|master\|dev\|develop" | xargs echo # | xargs git branch -d

