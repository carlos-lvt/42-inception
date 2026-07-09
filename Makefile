.PHONY: up down clean fclean re 

up:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build

down:

test:
	@mkdir -p /home/carlaugu/data/mariadb
	@docker compose -f srcs/docker-compose.yml up --build mariadb

ctest:
	@docker stop mariadb
	@docker rm mariadb
	@docker rmi mariadb:inception
	@docker volume rm srcs_wp_database
	@sudo rm -rf /home/carlaugu/data/

status:
	@docker images
	@echo ""	
	@docker ps -a
	@echo ""	
	@docker volume ls

clean:

fclean:
	@rm -rf /home/carlaugu/data/mariadb
	@rm -rf /home/carlaugu/data/wordpress

re: fclean up