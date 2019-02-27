#!/bin/bash

TODAY=`date +"%Y%m%d"`

cd /opt/JKSpot/
git add .
git commit -m "Auto Commit $TODAY" -a
git push
