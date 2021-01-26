FROM dpage/pgadmin4:latest

USER root
RUN apk update -f && apk upgrade -f && apk add bash

# PGADMIN CONFIGURATION
RUN mkdir /credentials && mkdir /servers && touch /credentials/pgpassfile
COPY /conf/servers.json /servers/servers.json
RUN chown -R pgadmin /servers && chown -R pgadmin /credentials

# ENTRYPOINT CONFIGURATION
COPY /scripts/default-entrypoint.sh /default-entrypoint.sh
COPY /scripts/init-dbs.sh /init-dbs.sh
RUN chown pgadmin /default-entrypoint.sh
RUN chown pgadmin /init-dbs.sh

WORKDIR /pgadmin4
USER pgadmin
ENTRYPOINT ["/default-entrypoint.sh"]