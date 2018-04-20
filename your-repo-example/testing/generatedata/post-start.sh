#!/bin/sh

docker exec -d dockerization_generatedata_1 /docker/tmp/fix-hosts.sh
docker exec -d adshares_landing_page_1 /docker/docker-start.sh
