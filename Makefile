.PHONY: up down clean fclean re 

up:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build

down:

test:
	@docker build -t test srcs/requirements/mariadb
	@docker run -it --name delete test

ctest:
	@docker rm delete
	@docker rmi test

status:
	@docker images
	@echo ""	
	@docker ps -a

clean:

fclean:
	@rm -rf /home/carlaugu/data/mariadb
	@rm -rf /home/carlaugu/data/wordpress

re: fclean up