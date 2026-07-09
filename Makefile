.PHONY: up down clean fclean re 

up:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build

down:

test:
	@docker build -t test srcs/requirements/mariadb
	@mkdir -p /tmp/test_data
	@docker run -it --name delete -v /tmp/test_data:/var/lib/mysql test

ctest:
	@docker stop delete
	@docker rm delete
	@docker rmi test
	@rm -rf /tmp/test_data

status:
	@docker images
	@echo ""	
	@docker ps -a

clean:

fclean:
	@rm -rf /home/carlaugu/data/mariadb
	@rm -rf /home/carlaugu/data/wordpress

re: fclean up