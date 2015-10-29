    docker run -it -p 8080:8080 -p 7077:7077 -p 6066:6066 --rm --name spark-master -e SPARK_MASTER_HOST=spark-master winkapp/spark-cluster-docker master

    docker run -it --link spark-master:spark-master -e SPARK_MASTER_URL=spark://spark-master:7077 winkapp/spark-cluster-docker slave
