#!/bin/bash

##################################
# CUSTOM SETTINGS CONFIGURATION
##################################

# Script Directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Script Variables
dbs=($CCDA_DB_NAME $SOLUTIONID_DB_NAME $CALC_DB_NAME)
users=($CCDA_DB_USER $SOLUTIONID_DB_USER $CALC_DB_USER)
passwords=($CCDA_DB_PASSWORD $SOLUTIONID_DB_PASSWORD $CALC_DB_PASSWORD)
nl=$'\n'

function log(){
    echo -e "\e[92m$(date +"%r")\e[0m: \e[4;32m$2\e[0m : >> $1"
}

function get_db_index(){
    for i in "${!dbs[@]}"
    do 
        if [[ "${dbs[$i]}" = "$1" ]]
        then
            echo "${i}"
        fi 
    done
}

function configure_pgadmin(){
    if [ -f "/credentials/pgpassfile" ]
    then
        > /credentials/pgpassfile
    fi

    log "Configuring PGPASSFILE for Admin User: $POSTGRES_USER" "configure_pgadmin"
    echo "$POSTGRES_HOST:$POSTGRES_PORT:*:$POSTGRES_USER:$POSTGRES_PASSWORD" >> /credentials/pgpassfile

    for i in ${dbs[@]}
    do
        db_index="$(get_db_index $i)"
        user=${users[$db_index]}
        password=${passwords[$db_index]}
        
        log "Configuring PGPASSFILE for User='$user' on Database='$i'" "configure_pgadmin"
        echo "$POSTGRES_HOST:$POSTGRES_PORT:$i:$user:$password" >> /credentials/pgpassfile
    done

    log "Configuring PGAdmin4's 'servers.json' With Secret Credentials" "configure_pgadmin"
    sed -i "s/__username__/$POSTGRES_USER/g" /servers/servers.json
    sed -i "s/__host__/$POSTGRES_HOST/g" /servers/servers.json
    sed -i "s/__port__/$POSTGRES_PORT/g" /servers/servers.json
    
}

log "Invoking 'configure_pgadmin' Function" "init-dbs_script"
configure_pgadmin

##################################
# START DEFAULT PGADMIN ENTRYPOINT
##################################

# Populate config_distro.py. This has some default config, as well as anything
# provided by the user through the PGADMIN_CONFIG_* environment variables.
# Only update the file on first launch. The empty file is created during the
# container build so it can have the required ownership.
if [ `wc -m /pgadmin4/config_distro.py | awk '{ print $1 }'` = "0" ]; then
    cat << EOF > /pgadmin4/config_distro.py
HELP_PATH = '../../docs'
DEFAULT_BINARY_PATHS = {
        'pg': '/usr/local/pgsql-13'
}
EOF

    # This is a bit kludgy, but necessary as the container uses BusyBox/ash as
    # it's shell and not bash which would allow a much cleaner implementation
    for var in $(env | grep PGADMIN_CONFIG_ | cut -d "=" -f 1); do
        echo ${var#PGADMIN_CONFIG_} = $(eval "echo \$$var") >> /pgadmin4/config_distro.py
    done
fi

if [ ! -f /var/lib/pgadmin/pgadmin4.db ]; then
    if [ -z "${PGADMIN_DEFAULT_EMAIL}" -o -z "${PGADMIN_DEFAULT_PASSWORD}" ]; then
        echo 'You need to specify PGADMIN_DEFAULT_EMAIL and PGADMIN_DEFAULT_PASSWORD environment variables'
        exit 1
    fi

    # Set the default username and password in a
    # backwards compatible way
    export PGADMIN_SETUP_EMAIL=${PGADMIN_DEFAULT_EMAIL}
    export PGADMIN_SETUP_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}

    # Initialize DB before starting Gunicorn
    # Importing pgadmin4 (from this script) is enough
    python run_pgadmin.py

    export PGADMIN_SERVER_JSON_FILE=${PGADMIN_SERVER_JSON_FILE:-/pgadmin4/servers.json}
    # Pre-load any required servers
    if [ -f "${PGADMIN_SERVER_JSON_FILE}" ]; then
        # When running in Desktop mode, no user is created
        # so we have to import servers anonymously
        if [ "${PGADMIN_CONFIG_SERVER_MODE}" = "False" ]; then
            /usr/local/bin/python /pgadmin4/setup.py --load-servers "${PGADMIN_SERVER_JSON_FILE}"
        else
            /usr/local/bin/python /pgadmin4/setup.py --load-servers "${PGADMIN_SERVER_JSON_FILE}" --user ${PGADMIN_DEFAULT_EMAIL}
        fi
    fi
fi

# Start Postfix to handle password resets etc.
if [ -z ${PGADMIN_DISABLE_POSTFIX} ]; then
    sudo /usr/sbin/postfix start
fi

# Get the session timeout from the pgAdmin config. We'll use this (in seconds)
# to define the Gunicorn worker timeout
TIMEOUT=$(cd /pgadmin4 && python -c 'import config; print(config.SESSION_EXPIRATION_TIME * 60 * 60 * 24)')

# NOTE: currently pgadmin can run only with 1 worker due to sessions implementation
# Using --threads to have multi-threaded single-process worker

# QUEUE UP DB CREATION AND SERVER POPULATION
# echo "post_start_setup" | at now +2 minutes

if [ ! -z ${PGADMIN_ENABLE_TLS} ]; then
    exec gunicorn --timeout ${TIMEOUT} --bind ${PGADMIN_LISTEN_ADDRESS:-[::]}:${PGADMIN_LISTEN_PORT:-443} -w 1 --threads ${GUNICORN_THREADS:-25} --access-logfile ${GUNICORN_ACCESS_LOGFILE:--} --keyfile /certs/server.key --certfile /certs/server.cert -c gunicorn_config.py run_pgadmin:app
else
    exec gunicorn --timeout ${TIMEOUT} --bind ${PGADMIN_LISTEN_ADDRESS:-[::]}:${PGADMIN_LISTEN_PORT:-80} -w 1 --threads ${GUNICORN_THREADS:-25} --access-logfile ${GUNICORN_ACCESS_LOGFILE:--} -c gunicorn_config.py run_pgadmin:app
fi