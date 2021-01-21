The <i>.env</i> file configures environment variables necessary for this projet to work. For more information on the <b>pgadmin</b> environment variables, see [here](https://www.pgadmin.org/docs/pgadmin4/development/container_deployment.html). For more information on the <b>postgres</b> environment variables, see [here](https://hub.docker.com/_/postgres) 

To starthe application, from the project root execute,

> docker-compose up -d

A <b>pgadmin</b> server will then be available at <i>localhost:5050</i>. You will need to login with the credentials defined in the PGADMIN_DEFAULT_EMAIL and PGADMIN_DEFAULT_PASSWORD.

If you can't login with the username/password combo defined in the <i>.env</i> file, then you may need to delete the <b>pgadmin</b> volume and recreate it. [See the following stack for more information](
https://stackoverflow.com/questions/65629281/pgadmin-docker-error-incorect-username-or-password)

Once logged in, you will need to add the database server to the list of servers. The database credentials are found in the POSTGRES_* environment variables.

# TODOS

1. Load in server connections before containers go up so user doesn't have to manually add the connections.

# Useful Links

- [Postgres Environment Variables](https://www.postgresql.org/docs/current/libpq-envars.html)
- [PGPASSFILE](https://www.postgresql.org/docs/8.3/libpq-pgpass.html)
- [How to use PGPASSFILE](https://stackoverflow.com/questions/22218142/how-to-use-pgpassfile-environment-variable)
- [Provisioning 'pgadmin' Container With Connections and Passwords](https://technology.amis.nl/continuous-delivery/provisioning/pgadmin-in-docker-provision-connections-and-passwords/)
- [Create Postgres DB if None Exists](https://notathoughtexperiment.me/blog/how-to-do-create-database-dbname-if-not-exists-in-postgres-in-golang/)
- [Pass SQL Scripts Parameters from Command Line](https://stackoverflow.com/questions/7389416/postgresql-how-to-pass-parameters-from-command-line)
- [Pass Dynamic Variables to PSQL](https://community.pivotal.io/s/article/How-to-pass-Dynamic-Variable-to-PSQL?language=en_US)
- [Create Database With User And Password](https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgres)
- [Get Index of Value In BASH Array](https://stackoverflow.com/questions/15028567/get-the-index-of-a-value-in-a-bash-array)
- [CMD vs ENTRYPOINT](https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile)
- [Postgres Syntax Error At Or Near IF](https://stackoverflow.com/questions/20957292/postgres-syntax-error-at-or-near-if)
- [Postgres If Statement](https://stackoverflow.com/questions/11299037/postgresql-if-statement)
- [Check If Database Exists From BASH](https://stackoverflow.com/questions/14549270/check-if-database-exists-in-postgresql-using-shell)