#!/bin/bash

echo
echo ALERT : THIS WILL REMOVE ALL YOUR DOCKER IMAGES AND CONTAINERS IN 15 seconds !!!!
echo
echo CTRL+C    - TO CANCEL
echo

sleep 15


for i in `docker ps -a | awk '{print $1}' | grep -v CONT`; do docker rm $i; done
for i in `docker images | awk '{print $3}' | grep -v IMAG`; do docker rmi -f $i; done
