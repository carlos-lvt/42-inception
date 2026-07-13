# User Documentation

This document explains, in simple terms, how to use the Inception
stack: what it does, how to start and stop it, how to reach the
site, and where to find your credentials.

## 1. What services does this stack provide?

The stack is made up of three containers, each with a single job:

- **NGINX** — the only entrypoint into the infrastructure. It
  serves the site over HTTPS (port 443) and forwards PHP requests
  to WordPress.
- **WordPress (with php-fpm)** — processes the site's PHP code
  and generates the pages you see in the browser.
- **MariaDB** — the database that stores everything WordPress
  needs: posts, pages, users, and site settings.

The three containers only talk to each other over an internal
Docker network. From outside the machine, only NGINX (port 443)
is reachable.

## 2. Starting and stopping the project

All commands are run from the root of the repository, using the provided `Makefile`. 
- Running `make up` creates the host folders, builds the images, sets up the network, and launches the containers. 

- Running `make down` stops the containers while keeping all data. Running `make clean` removes containers and images, but keeps the volumes and their data. 

- Running `make fclean` removes everything, including containers, images, volumes, and all stored data — use this only when you want a completely fresh start. 

- Running `make re` rebuilds everything from scratch by running `fclean` followed by `up`.

## 3. Accessing the website and the admin panel

Before the first access, the virtual machine needs to know that `<login>.42.fr` points to itself. Add this line to `/etc/hosts` 
**inside the virtual machine** (as root): 127.0.0.1 <login>.42.fr. This step is necessary because `<login>.42.fr` is not a real,
publicly registered domain.
Once that's done, open a browser **inside the virtual machine** and
go to `https://<login>.42.fr` for the website, or
`https://<login>.42.fr/wp-admin` for the WordPress admin panel.
Your browser will show a warning about the certificate being
self-signed — this is expected, since the project doesn't use a
certificate issued by a public authority. Accept the warning to
continue.

## 4. Locating and managing credentials

All passwords are stored as Docker secrets, in the `secrets/`
folder at the root of the repository (never committed to Git):

- `secrets/db_password.txt` — password for the WordPress database
  user.
- `secrets/db_root_password.txt` — password for the MariaDB root
  user.
- `secrets/wp_admin_password.txt` — password for the WordPress
  administrator account.
- `secrets/wp_user_password.txt` — password for the second
  WordPress account (non-administrator).

Non-sensitive configuration (domain name, database name, admin and
user emails, etc.) is stored in `srcs/.env`.

To change a password, edit the corresponding file in `secrets/`,
then run `make fclean` followed by `make up` so the change takes
effect on a fresh initialization.

## 5. Checking that services are running correctly

Run `docker compose -f srcs/docker-compose.yml ps` to check the status of all containers — all three should show a status of `Up`. 
If something looks wrong, check the logs of a specific service with `docker compose -f srcs/docker-compose.yml logs <service_name>`, 
replacing `<service_name>` with `nginx`, `wordpress`, or `mariadb`. If the website loads correctly at `https://<login>.42.fr`, 
all services are working together as expected.