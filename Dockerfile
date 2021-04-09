FROM dpage/pgadmin4:latest

USER root
RUN apk update -f && apk upgrade -f && apk add bash

# PGADMIN CONFIGURATION
RUN mkdir /credentials && mkdir /servers && touch /credentials/pgpassfile && chmod -c 600 /credentials/pgpassfile
COPY /conf/servers.json /servers/servers.json
COPY /scripts/init-dbs.sh /init-dbs.sh
COPY /scripts/configure-pgadmin.sh /configure-pgadmin.sh
# Overwrite default entrypoint
COPY /scripts/custom-entrypoint.sh /entrypoint.sh
RUN chown -R pgadmin:pgadmin /servers && chown -R pgadmin:pgadmin /credentials && \
    chown pgadmin:pgadmin /init-dbs.sh && chown pgadmin:pgadmin /configure-pgadmin.sh && \
    chown pgadmin:pgadmin /entrypoint.sh && chmod -c 770 /init-dbs.sh && \
    chmod -c 770 /configure-pgadmin.sh && chmod -c 770 /entrypoint.sh 
USER pgadmin

# TODO: (maybe?) manually set path since kubernetes overwrites it!

ENTRYPOINT [ "/entrypoint.sh" ]