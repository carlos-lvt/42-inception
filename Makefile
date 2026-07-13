.PHONY: up down clean fclean re

include srcs/.env
export

up:
	@mkdir -p /home/${LOGIN}/data/mariadb
	@mkdir -p /home/${LOGIN}/data/wordpress
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

re: fclean up


status:
	@docker images
	@echo ""	
	@docker ps -a
	@echo ""	
	@docker volume ls