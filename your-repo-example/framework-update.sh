#!/bin/bash

if [ -d "./dockerization-framework" ]
then
  (
    cd ./dockerization-framework
    git pull
  )
  echo
  echo DONE
  echo
else
  echo
  echo "Please install first"
  echo
fi
