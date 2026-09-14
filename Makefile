COMPOSE = docker compose -f srcs/docker-compose.yml

all: up

up:
	@mkdir -p /home/aelbouz/data/db_data
	@mkdir -p /home/aelbouz/data/wp_data
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down -v --rmi all --remove-orphans

fclean: clean
	docker system prune -af --volumes
	@sudo rm -rf /home/aelbouz/data

re: fclean all
