.PHONY: up down clean fclean re 

up:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build

down:
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@docker compose -f srcs/docker-compose.yml down --rmi all

fclean: clean
	@docker compose -f srcs/docker-compose.yml down -v
	@sudo rm -rf /home/carlaugu/data/mariadb
	@echo "Removed /home/carlaugu/data/mariadb"
	@sudo rm -rf /home/carlaugu/data/wordpress
	@echo "Removed /home/carlaugu/data/wordpress"

re: fclean up

status:
	@docker images
	@echo ""	
	@docker ps -a
	@echo ""	
	@docker volume ls