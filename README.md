The <i>.env</i> file configures environment variables necessary for this projet to work. For more information on the <b>pgadmin</b> environment variables, see [here](https://www.pgadmin.org/docs/pgadmin4/development/container_deployment.html). For more information on the <b>postgres</b> environment variables, see [here](https://hub.docker.com/_/postgres) 

To starthe application, from the project root execute,

> docker-compose up -d

A <b>pgadmin</b> server will then be available at <i>localhost:5050</i>. You will need to login with the credentials defined in the PGADMIN_DEFAULT_EMAIL and PGADMIN_DEFAULT_PASSWORD.

If you can't login with the username/password combo defined in the <i>.env</i> file, then you may need to delete the <b>pgadmin</b> volume and recreate it. [See the following stack for more information](
https://stackoverflow.com/questions/65629281/pgadmin-docker-error-incorect-username-or-password)

Once logged in, you will need to add the database server to the list of servers. The database credentials are found in the POSTGRES_* environment variables.

# TODOS

1. Load in server connections before containers go up so user doesn't have to manually add the connections.