#!/bin/bash
net_count_test=`docker network ls  | grep ' dockerization_net ' | wc -l`
if [ "$net_count_test" == "1" ]
then
  echo "NETWORK ALREADY EXISTS"
  exit
fi

docker network create --driver=bridge --subnet=172.16.111.0/24 --ip-range=172.16.111.0/24 --gateway=172.16.111.1 dockerization_net
echo "NEW NETWORK CREATED - dockerization_net"
