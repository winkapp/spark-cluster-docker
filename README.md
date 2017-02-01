## Quickstart

### With docker-compose

with docker and docker-compose available on your system

run `$ docker-compose up`

to spin up a single worker and master

`$ docker-compose down` will take them down again

`$ docker-compose scale spark-worker=X` will spin up `X` instances of spark workers and attach them to the master node.

have fun!

### With vanilla docker

*note: there seems to be a break with docker >= 1.12.6 in which --name is not causing the containers to resolve either internally (i.e. `SPARK_MASTER_HOST=spark-master`) or in --link*

To quickly spin up a Spark cluster, make sure you have Docker installed, and issue the following two commands (in different terminal windows):

    docker run -it -p 8080:8080 -p 7077:7077 -p 6066:6066 --rm \
    --name spark-master -e SPARK_MASTER_HOST=spark-master \
    winkapp/spark-standalone master

    docker run -it --link spark-master -e \
    SPARK_MASTER_URL=spark://spark-master:7077 \
    winkapp/spark-standalone worker

### Dynamic Resource Allocation
[Dynamic Resource Allocation](http://spark.apache.org/docs/latest/job-scheduling.html#dynamic-resource-allocation) is a feature offered in Spark standalone mode that allows a running job scale the number of executors it expects as the job resource consumption changes.

Executors (the members of worker nodes that perform `tasks`) are requested if the job has tasks waiting in queue, and are evicted if they remain idle for 60s (by default - this value is configurable)

It is enabled by starting a `shuffle-service` alongside each worker, that keeps state on shuffle file locations to prevent recalculating on killed executors.

However, a job will only _use_ dynamic resource allocation if the runtime has the following configuration:

|Property                         |Value |
|:-------------------------------:|-----:|
|`spark.shuffle.service.enabled`  |true  |
|`spark.dynamicAllocation.enabled`|true  |

this can be set in `/conf/spark-defaults.conf`,
in the runtime command: `spark-submit --conf spark.shuffle.service.enabled=true --confg spark.dynamicAllocation.enabled=true`
or in application code:

```scala
  val conf = new SparkConf()
    .set("spark.shuffle.service.enabled", "true") 
    .set("spark.dynamicAllocation.enabled", "true")
```

[Here's a good description of how it works](http://jerryshao.me/architecture/2015/08/22/spark-dynamic-allocation-investigation/)
[and a good description of why to user it](http://www.slideshare.net/databricks/dynamic-allocation-in-spark)
### Web UI & Healthcheck

After about a minute, you should be able to hit the spark web UI. If you are using OSX and docker-machine, go to http://{ip of docker host vm}:8080. If you don't know the ip of your docker host vm, try `docker-machine ls`. If you are using linux, just go to http://localhost:8080. You should see the Spark Web UI with one worker active.

to attach to a worker node ui you can run `docker-compose ps` or `docker-ps` to show the host port number each worker container's ui port (8081) is attached to

Now we will submit a job to make sure our cluster is working.

To create a job, we are actually going to inherit from the same docker image that we use to run the master and slave, but add in the code for our job. In the example below, we are running a python job on the cluster. Our file is called averageTimeUPC.py. Here is the Dockerfile we are using to build the image:

````
FROM winkapp/spark-standalone

RUN sudo apt-get update && sudo apt-get install -y python-dev python-pip build-essential gfortran libopenblas-dev liblapack-dev

RUN pip install numpy
RUN pip install scipy
RUN pip install boto

RUN mkdir ./apps

ADD averageTimeUPC.py ./apps/averageTimeUPC.py <== Add your own job code here

ENTRYPOINT ["/bin/bash"]
CMD ["./bin/spark-submit", "--master", "spark://spark-master:7077", "./apps/averageTimeUPC.py"] <== Make sure to also point to your own code here
````

Assuming you have built an image like the one above with your own code, we can now run the job against the cluster we have just created.

    docker run --link spark-master {Your image name}

## Not very quick start

The above example demonstrates how to run Spark on a single machine, where the containers can easily talk with one another, but once you actually want to run something in production, things get a bit more complex.

The primary problem to solve is networking between masters and workers.
