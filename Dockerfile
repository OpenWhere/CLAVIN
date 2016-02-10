FROM debian:jessie

ENV MAVEN_VERSION 3.3.9
ENV MAVEN_HOME /usr/share/maven
ENV LANG C.UTF-8

WORKDIR /opt/java
RUN apt-get update; apt-get install -y unzip curl openssl tar
ADD . /opt/java/.
RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
    \
    \
    curl -kfsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
    && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn && \
    curl -O http://download.geonames.org/export/dump/allCountries.zip && unzip allCountries.zip && rm allCountries.zip && \
    mvn install -Dmaven.test.skip=true && \
    MAVEN_OPTS="-Xmx4g" mvn exec:java -Dexec.mainClass="com.bericotech.clavin.index.IndexDirectoryBuilder" && \
    mkdir /etc/cliff2 && \
    ln -s /opt/java/IndexDirectory /etc/cliff2/IndexDirectory && \
    echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    rm -rf ~/.m2 && \
    rm allCountries.txt && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*
VOLUME ["/opt/java/IndexDirectoryBuilder", "/etc/cliff2/IndexDirectory"]
