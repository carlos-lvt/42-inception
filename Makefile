.PHONY: up down clean fclean re 

up:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build

down:
	@docker compose -f srcs/docker-compose.yml down

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