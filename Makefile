COMPOSE_FILE = ./srcs/docker-compose.yml
ENV_FILE = ./srcs/.env

all: build

build:
	grep -q "malapoug.42.fr" /etc/hosts || echo "127.0.0.1 malapoug.42.fr" | sudo tee -a /etc/hosts
	sudo systemctl enable docker
	sudo service start docker
	sudo mkdir -p /home/malapoug/data/wordpress
	sudo mkdir -p /home/malapoug/data/mariadb
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down -v

fclean:
	make clean
	docker system prune -af

re:
	make fclean
	make all

ps:
	docker compose -f $(COMPOSE_FILE) ps

logs:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

volume-ls:
	docker volume ls

.PHONY: all build down clean fclean re ps logs volume-ls
