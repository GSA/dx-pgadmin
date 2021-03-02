FROM dpage/pgadmin4:latest

USER root
RUN apk update -f && apk upgrade -f && apk add bash

# PGADMIN CONFIGURATION
RUN mkdir /credentials && mkdir /servers && touch /credentials/pgpassfile && chmod -c 600 /credentials/pgpassfile
COPY /conf/servers.json /servers/servers.json
RUN chown -R pgadmin /servers && chown -R pgadmin /credentials

# ENTRYPOINT CONFIGURATION
COPY /scripts/init-dbs.sh /init-dbs.sh
COPY /scripts/configure-pgadmin.sh /configure-pgadmin.sh
RUN chown pgadmin /init-dbs.sh

WORKDIR /pgadmin4
USER pgadmin