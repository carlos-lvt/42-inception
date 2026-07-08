.PHONY: up down clean fclean re 

up:
	@mkdir -p /home/carlaugu/data/mariadb
	@mkdir -p /home/carlaugu/data/wordpress
	docker compose up --build

down:

clean:

fclean:
	@rm -rf /home/carlaugu/data/mariadb
	@rm -rf /home/carlaugu/data/wordpress

re: fclean up