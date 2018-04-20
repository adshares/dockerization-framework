#!/bin/sh

until cd /www
do
    echo "Waiting for volume mount"
done

service php7.2-fpm start
