.PHONY: up down clean fclean re

include srcs/.env
export

DOMAIN_VAL=$(shell grep "carlaugu.42.fr" /etc/hosts)

up:
	@mkdir -p /home/${LOGIN}/data/mariadb
	@mkdir -p /home/${LOGIN}/data/wordpress
	@if [ -z "${DOMAIN_VAL}" ]; then \
		echo "127.0.0.1  carlaugu.42.fr" | sudo tee -a /etc/hosts > /dev/null; \
		echo "added carlaugu.42.fr to /etc/hosts"; \
	fi
	@docker compose -f srcs/docker-compose.yml up --build

down:
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@docker compose -f srcs/docker-compose.yml down --rmi all

fclean: clean
	@docker compose -f srcs/docker-compose.yml down -v
	@sudo rm -rf /home/${LOGIN}/data/mariadb
	@echo "Removed /home/${LOGIN}/data/mariadb"
	@sudo rm -rf /home/${LOGIN}/data/wordpress
	@echo "Removed /home/${LOGIN}/data/wordpress"
	@sudo sed -i '/carlaugu.42.fr/d' /etc/hosts
	@echo "Removed carlaugu.42.fr from /etc/hosts"

re: fclean up

status:
	@docker images
	@echo ""	
	@docker ps -a
	@echo ""	
	@docker volume ls