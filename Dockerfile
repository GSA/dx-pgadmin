FROM dpage/pgadmin4:latest

USER root
WORKDIR /pgadmin4
RUN apk update -f && apk upgrade -f && apk add bash

# PGADMIN CONFIGURATION
RUN mkdir /credentials && mkdir /servers && touch /credentials/pgpassfile && chmod -c 600 /credentials/pgpassfile
COPY /conf/servers.json /servers/servers.json
COPY /scripts/init-dbs.sh /init-dbs.sh
COPY /scripts/configure-pgadmin.sh /configure-pgadmin.sh
COPY /scripts/custom-entrypoint.sh /entrypoint.sh
RUN chown -R pgadmin:pgadmin /servers && chown -R pgadmin:pgadmin /credentials && \
    chown pgadmin:pgadmin /init-dbs.sh /configure-pgadmin.sh /entrypoint.sh
USER pgadmin