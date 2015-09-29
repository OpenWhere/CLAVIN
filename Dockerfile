FROM openwhere/java-base:ttl

WORKDIR /opt/java
RUN yum install -y unzip
RUN curl -O http://download.geonames.org/export/dump/allCountries.zip && unzip allCountries.zip && rm allCountries.zip
ADD . /opt/java/.
RUN MAVEN_OPTS="-Xmx4g" mvn exec:java -Dexec.mainClass="com.bericotech.clavin.index.IndexDirectoryBuilder" 
RUN mkdir /etc/cliff2
RUN ln -s /opt/java/IndexDirectory /etc/cliff2/IndexDirectory
VOLUME ["/opt/java/IndexDirectoryBuilder", "/etc/cliff2/IndexDirectory"]
