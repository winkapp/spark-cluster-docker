#!/bin/bash

CMD=${1:-"exit 0"}

# mount the NFS jobs share
# which are we mounting?
MOUNT_PATH="/nfs/integration" # int by default
if [[ $SPARK_ENV != "" ]]; then
  MOUNT_PATH="/nfs/${SPARK_ENV}"
fi
echo "Mounting $MOUNT_PATH to /mnt/nfs"
sudo mount -t nfs -o resvport,nolock,v3 spark-nfs.wink.com:$MOUNT_PATH /mnt/nfs

# start spark-standalone in the appropriate configuration
if [[ "$CMD" == "master" ]]; then
  /bin/bash -c "$SPARK_HOME/sbin/start-master.sh -h $SPARK_MASTER_HOST"
  /bin/bash -c "tail -f $SPARK_HOME/logs/spark--org.apache.spark.deploy.master.Master*"
elif [[ "$CMD" == "worker" ]]; then
  /bin/bash -c "$SPARK_HOME/sbin/start-slave.sh $SPARK_MASTER_URL"
  /bin/bash -c "tail -f $SPARK_HOME/logs/spark--org.apache.spark.deploy.worker.Worker*"
else
  /bin/bash -c "$*"
fi
