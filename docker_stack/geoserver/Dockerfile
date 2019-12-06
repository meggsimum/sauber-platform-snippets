# Use a minimal tomcat image as parent
FROM tomcat:9.0-jre8
LABEL maintainer="Christian Mayer<chris@meggsimum.de>"

# The GS_VERSION argument could be used like this to overwrite the default:
# docker build --build-arg GS_VERSION=2.11.3 -t geoserver:2.11.3 .
ARG GS_VERSION=2.13.2
ARG GS_DATA_PATH=./geoserver_data/
ARG ADDITIONAL_LIBS_PATH=./additional_libs/

# Environment variables
ENV GEOSERVER_VERSION=$GS_VERSION
ENV MARLIN_TAG=0_9_2
ENV MARLIN_VERSION=0.9.2
ENV GEOSERVER_INIT_DATA_DIR=/opt/geoserver_init_data
ENV GEOSERVER_LIB_DIR=$CATALINA_HOME/webapps/geoserver/WEB-INF/lib/

# see http://docs.geoserver.org/stable/en/user/production/container.html
ENV CATALINA_OPTS='-Xms256m -Xmx1g -Dfile.encoding=UTF-8 -D-XX:SoftRefLRUPolicyMSPerMB=36000 -Xbootclasspath/a:$CATALINA_HOME/lib/marlin.jar -Xbootclasspath/p:$CATALINA_HOME/lib/marlin-sun-java2d.jar -Dsun.java2d.renderer=org.marlin.pisces.PiscesRenderingEngine -Dorg.geotools.coverage.jaiext.enabled=true'

WORKDIR /tmp

# init
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y curl && \
    apt-get install -y openssl && \
    rm -rf $CATALINA_HOME/webapps/*

# install geoserver
RUN curl -jkSL -o /tmp/geoserver.zip http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-war.zip && \
    unzip geoserver.zip geoserver.war -d $CATALINA_HOME/webapps && \
    mkdir $CATALINA_HOME/webapps/geoserver && \
    unzip -q $CATALINA_HOME/webapps/geoserver.war -d $CATALINA_HOME/webapps/geoserver && \
    rm $CATALINA_HOME/webapps/geoserver.war && \
    mkdir $GEOSERVER_INIT_DATA_DIR

COPY $GS_DATA_PATH $GEOSERVER_INIT_DATA_DIR
COPY $ADDITIONAL_LIBS_PATH $GEOSERVER_LIB_DIR

# Add Cors filter and filter mapping.
COPY resources/conf/web.xml $CATALINA_HOME/conf/web.xml

# Add preconfigured JNDI datasources.
COPY resources/conf/context.xml $CATALINA_HOME/conf/context.xml

# Add a script to pass environment vars into tomcat.
COPY resources/bin/setenv.sh $CATALINA_HOME/bin/setenv.sh
RUN chmod 775 $CATALINA_HOME/bin/setenv.sh

# Add the postgresql driver to tomcat for JNDI access.
COPY resources/lib/postgresql-42.2.5.jar $CATALINA_HOME/lib/postgresql-42.2.5.jar
RUN chmod 775 $CATALINA_HOME/lib/postgresql-42.2.5.jar

# install java advanced imaging
RUN wget https://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz && \
    wget https://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    gunzip -c jai-1_1_3-lib-linux-amd64.tar.gz | tar xf - && \
    gunzip -c jai_imageio-1_1-lib-linux-amd64.tar.gz | tar xf - && \
    mv /tmp/jai-1_1_3/lib/*.jar $JAVA_HOME/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/*.so $JAVA_HOME/lib/amd64/ && \
    mv /tmp/jai_imageio-1_1/lib/*.jar $JAVA_HOME/lib/ext/ && \
    mv /tmp/jai_imageio-1_1/lib/*.so $JAVA_HOME/lib/amd64/

# uninstall JAI default installation and postgres sql driver from geoserver to avoid classpath conflicts
# see http://docs.geoserver.org/latest/en/user/production/java.html#install-native-jai-and-imageio-extensions
WORKDIR $GEOSERVER_LIB_DIR
RUN rm jai_core-*jar jai_imageio-*.jar jai_codec-*.jar
RUN rm postgresql-*.jar

# install marlin renderer
RUN curl -jkSL -o $CATALINA_HOME/lib/marlin.jar https://github.com/bourgesl/marlin-renderer/releases/download/v$MARLIN_TAG/marlin-$MARLIN_VERSION-Unsafe.jar && \
    curl -jkSL -o $CATALINA_HOME/lib/marlin-sun-java2d.jar https://github.com/bourgesl/marlin-renderer/releases/download/v$MARLIN_TAG/marlin-$MARLIN_VERSION-Unsafe-sun-java2d.jar

# Install our custom script to deploy module data.
COPY resources/bin/import-data.sh /usr/local/bin
RUN chmod 775 /usr/local/bin/import-data.sh

# cleanup
# RUN apk del curl && \
#     rm -rf /tmp/* /var/cache/apk/*
RUN rm -rf /tmp/* /var/cache/apk/*

WORKDIR /
