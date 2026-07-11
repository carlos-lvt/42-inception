.PHONY: up down clean fclean re 

up:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build

down:
	@docker compose -f srcs/docker-compose.yml down

test:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build wordpress

exec:
	@docker exec -it wordpress bash

ctest:
	@docker compose -f srcs/docker-compose.yml down -v wordpress
	@docker compose -f srcs/docker-compose.yml down -v mariadb
	@docker rmi wordpress:inception
	@docker rmi mariadb:inception
	@sudo rm -rf /home/carlaugu/data/
	@$(MAKE) status

status:
	@docker images
	@echo ""	
	@docker ps -a
	@echo ""	
	@docker volume ls

clean:
	@docker compose -f srcs/docker-compose.yml down -v --rmi all

fclean: clean
	@sudo rm -rf /home/carlaugu/data/mariadb
	@sudo rm -rf /home/carlaugu/data/wordpress

re: fclean up