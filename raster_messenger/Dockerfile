FROM maven:3.6.0-jdk-8-slim
LABEL maintainer="Julian Kaeflein<julian.kaeflein@geomer.de>"

ENV UM_SERVER="host.docker.internal:9876"
ENV UM_CHANNEL="raster_data"
ENV OFFSET_HRS="0"
ENV TEST_REGION="TestRegion"
ENV TEST_POLLUTANT="TestSchad"

WORKDIR /opt

# copy the maven project
COPY local-deps/ local-deps/
COPY src/ src/
COPY pom.xml pom.xml

# install local dependency for UM Java client
RUN mvn install:install-file -Dfile=local-deps/nClient.jar -DgroupId=com.pcbsys.nirvana.client -DartifactId=sample -Dversion=1.0 -Dpackaging=jar

# build the executable JAR file
RUN mvn clean package -DskipTests

CMD UMCHANNEL=$UM_CHANNEL UMSERVER=$UM_SERVER OFFSETHRS=$OFFSET_HRS TESTREGION=$TEST_REGION TESTPOLLUTANT=$TEST_POLLUTANT java -jar target/test-messenger-jar-with-dependencies.jar
