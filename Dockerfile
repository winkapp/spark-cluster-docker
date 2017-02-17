FROM ubuntu:14.04
MAINTAINER Wink

RUN apt-get update; apt-get install -y curl default-jdk

# install some stuff we know we'll need to support Python stuff in distribution on the workers
RUN apt-get install -y \
  python-dev \
  python-pip \
  && pip install \
    boto \
    bz2file


RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.0-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.0-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
ENV PATH $SPARK_HOME/bin:$PATH
# set the python path explicitly because spark looks in the wrong spot by default
ENV PYTHONPATH `echo "import sys; print ':'.join(sys.path)" | ython`:$PYTHONPATH
ADD bootstrap.sh /usr/local/bootstrap.sh
ENTRYPOINT ["/usr/local/bootstrap.sh"]
WORKDIR /usr/local/spark
