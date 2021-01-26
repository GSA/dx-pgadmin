# Script Directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Script Variables
dbs=($CCDA_DB_NAME $SOLUTIONID_DB_NAME $CALC_DB_NAME)
users=($CCDA_DB_USER $SOLUTIONID_DB_USER $CALC_DB_USER)
passwords=($CCDA_DB_PASSWORD $SOLUTIONID_DB_PASSWORD $CALC_DB_PASSWORD)
nl=$'\n'

# Script Functions
function log(){
    echo -e "\e[92m$(date +"%r")\e[0m: \e[4;32m$2\e[0m : >> $1"
}

function print_line(){
    echo "-------------------------"
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

function execute_sql(){
    log "PGPASSWORD=xxxx psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER" "execute_sql"
    PGPASSWORD=$POSTGRES_PASSWORD psql --echo-errors --host=$POSTGRES_HOST --port=$POSTGRES_PORT --username=$POSTGRES_USER --command="$1"
}

function list_databases(){
    PGPASSWORD=$POSTGRES_PASSWORD psql --echo-errors --host=$POSTGRES_HOST --port=$POSTGRES_PORT --username=$POSTGRES_USER -lqt
}

function database_exists(){
    if list_databases | cut -d \| -f 1 | grep -qw "$1" 
    then
        echo 0
    else
        echo 1
    fi
}

function create_dbs(){
    if [ "$APP_ENV" == "local" ] 
    then
        sleep 5s
    fi

    for i in ${dbs[@]}
    do
        exists=$(database_exists $i)

        if [ "$exists" == 0 ]
        then
            log "NOTE: $i Database Already Exists, Skipping Creation" "create_dbs"
        else
            db_index="$(get_db_index $i)"
            user=${users[$db_index]}
            password=${passwords[$db_index]}

            print_line
            log "$i Database Configuration" "create_dbs"
            print_line

            log "Creating Database='$i'" "create_dbs"
            CREATE_CMD="CREATE DATABASE $i;"
            execute_sql "$CREATE_CMD"

            log "Creating User='$user'" "create_dbs"
            USER_CMD="CREATE USER $user WITH ENCRYPTED PASSWORD '$password';"
            execute_sql "$USER_CMD"

            log "Granting User='$user' All Privileges On Database='$i'" "create_dbs"
            GRANT_CMD="GRANT ALL PRIVILEGES ON DATABASE $i TO $user;"
            execute_sql "$GRANT_CMD"
        fi
        
    done
    print_line

}

function configure_pgadmin(){
    if [ -f "/credentials/pgpassfile" ]
    then
        rm -R /credentials/pgpassfile
    fi

    log "Configuring PGPASSFILE for Admin User: $POSTGRES_USER" "configure_pgadmin"
    touch /credentials/pgpassfile
    echo "$POSTGRES_HOST:$POSTGRES_PORT:*:$POSTGRES_USER:$POSTGRES_PASSWORD ${nl}" >> /credentials/pgpassfile

    for i in ${dbs[@]}
    do
        db_index="$(get_db_index $i)"
        user=${users[$db_index]}
        password=${passwords[$db_index]}
        
        log "Configuring PGPASSFILE for User='$user' on Database='$i'" "configure_pgadmin"
        echo "$POSTGRES_HOST:$POSTGRES_PORT:$i:$user:$password ${nl}" >> /credentials/pgpassfile
    done

    log "Configuring PGAdmin4's 'servers.json' With Secret Credentials" "configure_pgadmin"
    sed -i "s/__username__/$POSTGRES_USER/g" /servers/servers.json
    sed -i "s/__host__/$POSTGRES_HOST/g" /servers/servers.json
    sed -i "s/__port__/$POSTGRES_PORT/g" /servers/servers.json
    
}

log "Executing From $SCRIPT_DIR" "init-dbs_script"

# Script Procedure
log "Invoking 'create_dbs' Function" "init-dbs_script"
create_dbs

log "Invoking 'configure_pgadmin' Function" "init-dbs_script"
configure_pgadmin

log "Loading Servers Into pgadmin" "init-dbs_script"
python $SCRIPT_DIR/pgadmin4/setup.py --load-servers $CUSTOM_SERVER_JSON_FILE --user $PGADMIN_DEFAULT_EMAIL
