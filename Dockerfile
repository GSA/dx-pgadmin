FROM dpage/pgadmin4:latest

USER root
RUN apk update -f && apk upgrade -f && apk add bash

WORKDIR /pgadmin4
COPY entrypoint.sh /entrypoint.sh

USER pgadmin
WORKDIR /pgadmin4
ENTRYPOINT ["/entrypoint.sh"]