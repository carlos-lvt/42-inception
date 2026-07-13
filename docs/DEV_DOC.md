# Developer Documentation

This document explains how to set up the development environment from scratch, build and run the project, and manage its containers and data.

## 1. Setting up the environment from scratch

**Prerequisites:** a Debian virtual machine, with Docker Engine and Docker Compose installed ([official instructions](https://docs.docker.com/engine/install/debian/)). Add your user to the `docker` group to run commands without `sudo`: sudo usermod -aG docker $USER

**Configuration files** (never committed to Git, must be created manually):

1. `srcs/.env` — non-sensitive settings such as `DOMAIN_NAME`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_HOST`.
2. `secrets/` folder, containing `db_password.txt`, `db_root_password.txt`, `wp_admin_password.txt`, and `wp_user_password.txt` — each with a single password, no extra whitespace.

**Domain name:** add this line to `/etc/hosts` on the virtual machine: 127.0.0.1    <login>.42.fr

## 2. Building and launching the project

Everything is driven by the `Makefile` at the root of the repository:

- `make up` — creates the host data folders, builds the images, and starts all containers.
- `make down` — stops the containers, keeping all data.
- `make clean` — removes containers and images.
- `make fclean` — removes containers, images, volumes, and their host data folders (full reset).
- `make re` — runs `fclean` followed by `up`.

Under the hood, these targets call: docker compose -f srcs/docker-compose.yml up --build -d

`--build` is always used, to force rebuilding images from the local Dockerfiles instead of pulling from a registry.

## 3. Managing containers and volumes

Useful commands, run from the repository root: check container status with `docker compose -f srcs/docker-compose.yml ps`; follow logs for a specific service with `docker compose -f srcs/docker-compose.yml logs -f <service>`, replacing `<service>` with `mariadb`, `wordpress`, or `nginx`; open a shell inside a running container with `docker compose -f srcs/docker-compose.yml exec <service> bash`; list all Docker volumes with `docker volume ls`; and inspect a specific volume, which also shows its host path, with `docker volume inspect srcs_wp_database`.

## 4. Where project data is stored and how it persists

The project uses two named volumes, both configured with `driver_opts` so their data is physically stored on the host. `wp_database` is mounted at `/var/lib/mysql` inside the `mariadb` container, and on the host its data lives at `/home/<login>/data/mariadb`. `wp_files` is mounted at `/var/www/html` inside both the `wordpress` and `nginx` containers (shared, so NGINX can serve static files and forward PHP requests to WordPress), and on the host its data lives at `/home/<login>/data/wordpress`. Because these are Docker-managed named volumes, the data persists across container restarts and recreations — it is only deleted by `make fclean`, which explicitly removes both the Docker volumes and their corresponding host folders.