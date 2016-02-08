FROM ubuntu:14.04
MAINTAINER Wink

RUN apt-get update; apt-get install -y curl default-jdk nfs-common

RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.5.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.5.1-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark

# make a mountpoint for the nfs share with the jobs in it
RUN mkdir -p /mnt/nfs

EXPOSE 8080 7077 6066

ADD bootstrap.sh /usr/local/bootstrap.sh
ENTRYPOINT ["/usr/local/bootstrap.sh"]
WORKDIR /usr/local/spark
