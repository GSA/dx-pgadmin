# Quickstart

Copy the <i>.sample.env</i> file into a new <i>.env</i> file,

> cp .sample.env .env

The <i>.env</i> file configures environment variables necessary for this project to work. For more information on the <b>pgadmin</b> environment variables, see [here](https://www.pgadmin.org/docs/pgadmin4/development/container_deployment.html). For more information on the <b>postgres</b> environment variables, see [here](https://hub.docker.com/_/postgres) 

In order for the application cluster to work, you will need to adjust <b>POSTGRES_HOST</b> (for containers, the host should be set equal to the name of the database service defined in the <i>docker-compose.yml</i>), <b>POSTGRES_USER</b>, <b>POSTGRES_PASSWORD</b>, <b>PGADMIN_DEFAULT_USER</b>, <b>PGADMIN_DEFAULT_EMAIL</b> and for each application whose database server you want to be able to see in <b>pgadmin</b>, you will need to adjust <b>_DB_NAME</b> (name of database), <b>_DB_USER</b> (user with permissions to access database) and <b>_DB_PASSWORD</b> (the password for the user just defined) variables. You can create more application database connections by adding them to the <i>.env</i> file and then adding those environment variables to the arrays defined in the BASH entrypoint script <i>entrypoint.sh</i>. Specifically, add your newly created database variables to lines 7 - 9,

> dbs=($CCDA_DB_NAME $SOLUTIONID_DB_NAME $CALC_DB_NAME) <br>
> users=($CCDA_DB_USER $SOLUTIONID_DB_USER $CALC_DB_USER) <br>
> passwords=($CCDA_DB_PASSWORD $SOLUTIONID_DB_PASSWORD $CALC_DB_PASSWORD)<br>

To start the application, from the project root execute,

> docker-compose up -d

A <b>pgadmin</b> server will then be available at <i>localhost:5050</i>. You will need to login with the credentials defined in the PGADMIN_DEFAULT_EMAIL and PGADMIN_DEFAULT_PASSWORD. The databases defined by the (_DB_NAME, _DB_USER, _DB_PASSWORD)-tuples will be populated in the pgadmin server list during initialization and should be available when you log in. The server group with the database connections is only initialized when the configuration databases for postgres and pgadmin are first created. If a deployment doesn't finish initializing or gets interrupted, you may not see the server group when you log in. If you do not, you will need to take down the application cluster and remove the volumes associated with it so the application cluster can be deployed within a fresh environment. 

Along those lines, if you can't login with the username/password combo defined in the <i>.env</i> file, then you may need to delete the <b>pgadmin</b> volume and recreate it. [See the following stack for more information](
https://stackoverflow.com/questions/65629281/pgadmin-docker-error-incorect-username-or-password)

IMPORTANT! Due to the way MCaaS is setup, the database creation script has to be run after the pod is healthy. The script <i>init-dbs</i> needs to be executed inside of the <b>pgadmin</b> container after the pod launches to initialize the databases within the <b>postgres</b> server. Remember, we do not have access to the postgres service, so all database initialize has to be done with in the <b>pgadmin</b> container.

To create the databases after the container is spun up, start a shell session inside of the container and execute the necessary script,

`docker exec -it dx-pgadmin_pgadmin_1 bash`<br>
`/init-dbs.sh`<br>

On the MCaaS environment, the admins will need to manually exec into the pod to execute this script. This process must be done everytime a database is initialized in a new environment.

# Tips

If you need to launch the application fresh, i.e. recreate the pgadmin and postgres configuration databases, recreate databases, etc, then you need to make sure you wipe the Docker volumes mounted through the <i>docker-compose.yml</i>; <i>docker-compose down</i> is not sufficient. You can use the <i>/scripts/detonate.sh</i> to purge your local Docker of all traces of this application. After invoking the script, the next <i>docker-compose up</i> will recreate the images, volumes and network. 

This is especially important if you happen to change the <b>PGADMIN_DEFAULT_EMAIL</b> and <b>PGADMIN_DEFAULT_PASSWORD</b>, as the retained volumes will persist the old values of these environment variables until the volume is pruned.

# Useful Links

## Postgres
- [Postgres Environment Variables](https://www.postgresql.org/docs/current/libpq-envars.html)
- [PGPASSFILE](https://www.postgresql.org/docs/8.3/libpq-pgpass.html)
- [How to use PGPASSFILE](https://stackoverflow.com/questions/22218142/how-to-use-pgpassfile-environment-variable)
- [Pass SQL Scripts Parameters from Command Line](https://stackoverflow.com/questions/7389416/postgresql-how-to-pass-parameters-from-command-line)
- [Pass Dynamic Variables to PSQL](https://community.pivotal.io/s/article/How-to-pass-Dynamic-Variable-to-PSQL?language=en_US)
- [Create Database With User And Password](https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgres)
- [Create Postgres DB if None Exists](https://notathoughtexperiment.me/blog/how-to-do-create-database-dbname-if-not-exists-in-postgres-in-golang/)
- [Postgres Syntax Error At Or Near IF](https://stackoverflow.com/questions/20957292/postgres-syntax-error-at-or-near-if)
- [Postgres If Statement](https://stackoverflow.com/questions/11299037/postgresql-if-statement)

## PGAdmin
- [PGAdmin4 Docker Repo](https://hub.docker.com/r/dpage/pgadmin4/)
- [PGAdmin4 Container Git Repo](https://github.com/postgres/pgadmin4)
- [PGAdmin Container Deployment](https://www.enterprisedb.com/edb-docs/d/pgadmin-4/reference/online-documentation/4.14/container_deployment.html)
- [Provisioning PGAdmin Container With Connections and Passwords](https://technology.amis.nl/continuous-delivery/provisioning/pgadmin-in-docker-provision-connections-and-passwords/)
- [PGAdmin4 Import/Export Servers](https://www.pgadmin.org/docs/pgadmin4/development/import_export_servers.html)
- [PGAdmin Helm Chart Example](https://github.com/rowanruseler/helm-charts/blob/master/charts/pgadmin4/values.yaml)
- [pg_restore file not found](https://unix.stackexchange.com/questions/561080/usr-bin-pg-restore-file-not-found-please-correct-the-binary-path-in-the-pref)
- [Preferences](https://www.pgadmin.org/docs/pgadmin4/development/preferences.html)

## BASH
- [Get Index of Value In BASH Array](https://stackoverflow.com/questions/15028567/get-the-index-of-a-value-in-a-bash-array)
- [CMD vs ENTRYPOINT](https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile)
- [Check If Database Exists From BASH](https://stackoverflow.com/questions/14549270/check-if-database-exists-in-postgresql-using-shell)
- [Append to File](https://stackoverflow.com/questions/6207573/how-to-append-output-to-the-end-of-a-text-file)

## Kubernetes
- [Configure Pod Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)