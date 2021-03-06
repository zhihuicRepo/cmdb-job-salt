#!/bin/bash

# Start the first process
/usr/bin/salt-master -d
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start salt-master: $status"
  exit $status
fi

# Start the second process
nohup python /job/django_cmdb_project/manage.py  runserver 0.0.0.0:8000 > /var/log/job.log 2>&1 &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start django : $status"
  exit $status
fi


while sleep 60; do
  ps aux | grep salt-master | grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux | grep cmdb | grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
