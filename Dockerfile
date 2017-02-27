FROM steigr/java:8_server-jre_unlimited

ENV  APPLICATION_USER=confluence \
		 CONFLUENCE_VERSION=6.0.6 \
		 TOMCAT_VERSION=8.5.11

RUN  addgroup -S $APPLICATION_USER \
 &&  adduser -h /app -G $APPLICATION_USER -g '' -S -D -H $APPLICATION_USER \
 &&  apk add --no-cache --virtual .build-deps tar curl \
 &&  install -D -d -o $APPLICATION_USER -g $APPLICATION_USER /app \
 &&  curl -L https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz \
     | su-exec $APPLICATION_USER tar -x -z -C /app --strip-components=1 \
 &&  rm -rf /app/lib/hsqldb-*.jar \
            /app/lib/postgresql-*.jar \
            /app/README* \
            /app/NOTICE* \
            /app/licenses \
            /app/tomcat-docs \
 &&  xml c14n --without-comments /app/conf/server.xml | xml fo -s 2 > /app/conf/server.xml.tmp \
 &&  mv /app/conf/server.xml.tmp /app/conf/server.xml \
 &&  curl -Lo /app/lib/hsqldb-2.3.4.jar http://central.maven.org/maven2/org/hsqldb/hsqldb/2.3.4/hsqldb-2.3.4.jar \
 &&  curl -Lo /app/lib/postgresql-42.0.0.jar https://jdbc.postgresql.org/download/postgresql-42.0.0.jar \
 &&  curl -sL http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION:0:1}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
     | su-exec $APPLICATION_USER tar -x -z -v -C /app --strip-components=1 --wildcards "apache-tomcat-${TOMCAT_VERSION}/bin/*" "apache-tomcat-${TOMCAT_VERSION}/lib/*" \
 &&  apk del .build-deps \
 &&  rm -rf /var/cache/apk/*

RUN  export MIDANAUTHENTICATOR_VERSION=1.1.0 \
 &&  apk add --no-cache --virtual .build-deps curl \
 &&  curl -L https://github.com/MIDAN-SOFTWARE/MIDANAuthenticator/releases/download/${MIDANAUTHENTICATOR_VERSION}/midan-authenticator-${MIDANAUTHENTICATOR_VERSION:0:3}.jar \
     | install -D -o $APPLICATION_USER -g $APPLICATION_USER -m 0644 /dev/stdin /app/atlassian-confluence/WEB-INF/lib/midan-authenticator-${MIDANAUTHENTICATOR_VERSION:0:3}.jar \
 &&  apk del .build-deps \
 &&  rm -rf /var/cache/apk/*

HEALTHCHECK CMD nc -z 127.0.0.1 8090

VOLUME /app/.oracle_jre_usage /app/work /app/logs /tmp
ENTRYPOINT ["confluence"]
ADD docker-entrypoint.sh /bin/confluence

ADD scripts/main /main
ADD scripts/vars /vars
ADD scripts/crowd-sso-configurator  /crowd-sso-configurator
ADD scripts/confluence-configurator /confluence-configurator