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

log "Loading Servers Into pgadmin" "init-dbs_script"
python $SCRIPT_DIR/pgadmin4/setup.py --load-servers $CUSTOM_SERVER_JSON_FILE --user $PGADMIN_DEFAULT_EMAIL