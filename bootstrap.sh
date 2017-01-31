#!/bin/bash

CMD=${1:-"exit 0"}
WORKER_MEM=${SPARK_WORKER_MEM:-"1G"}

if [[ "$CMD" == "master" ]]; then
  /bin/bash -c "$SPARK_HOME/sbin/start-master.sh -h $SPARK_MASTER_HOST"
  /bin/bash -c "tail -f $SPARK_HOME/logs/spark--org.apache.spark.deploy.master.Master*"
elif [[ "$CMD" == "worker" ]]; then
  /bin/bash -c "$SPARK_HOME/sbin/start-slave.sh -m $WORKER_MEM $SPARK_MASTER_URL"
  /bin/bash -c "$SPARK_HOME/sbin/start-shuffle-service.sh"
  /bin/bash -c "tail -f $SPARK_HOME/logs/spark--org.apache.spark.deploy.worker.Worker*"
else
  /bin/bash -c "$*"
fi
