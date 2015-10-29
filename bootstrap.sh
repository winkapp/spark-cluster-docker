#!/bin/bash


CMD=${1:-"exit 0"}
if [[ "$CMD" == "master" ]]; then
  /bin/bash -c "$SPARK_HOME/sbin/start-master.sh"
elif [[ "$CMD" == "slave" ]]; then
  /bin/bash -c "$SPARK_HOME/sbin/start-slave.sh $SPARK_MASTER_URL"
else
  /bin/bash -c "$*"
fi
