docker-compose down

docker volume rm dx-pgadmin_postgres dx-pgadmin_pgadmin

docker system prune -f

docker rmi $(docker images --filter "dangling=true" -q)