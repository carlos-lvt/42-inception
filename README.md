*This project has been created as part of the 42 curriculum by carlaugu*

## Description
Inception is a system administration project that sets up a small, containerized web infrastructure using Docker Compose. It includes three services: NGINX (with TLS), WordPress with php-fpm, and MariaDB, each running in its own container, built from custom Dockerfiles, with persistent data storage via Docker volumes. The goal is to gain hands-on experience with Docker fundamentals: image building, networking, volumes, and secrets management.

## Instructions

- Run inside a virtual machine to avoid security issues on the host system.

- `make up` (or `make`)
  - Creates the host folders for the volumes, builds the Docker images,
    sets up the network, and starts the containers.

- `make down`
  - Stops and removes the containers (volumes and data are preserved).

- `make clean`
  - Removes containers and images. Volumes and their host folders
    are preserved.

- `make fclean`
  - Runs `clean`, then also removes the Docker volumes and their
    corresponding host folders (all persisted data is lost).

- `make re`
  - Runs `fclean` followed by `up` — a full rebuild from scratch.

## Resources

- https://docs.docker.com/get-started/
- https://contabo.com/blog/containers-vs-virtual-machines/
- https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok
- https://www.youtube.com/watch?v=uBuhpBr0KCQ&list=PLft9u7_h34bE

### Usage of AI

AI (Claude) was used as a mentor throughout the project, mainly to:
- Clarify Docker/Linux concepts (image vs container, PID 1, named
  volumes vs bind mounts).
- Debug specific errors during development.
- Review and correct scripts/configuration files I had already
  written, explaining *why* a change was needed.
- Help structure this documentation.

AI was not used to generate whole scripts or files without
understanding them. Every solution was tested, and I can explain
the reasoning behind each part of the `entrypoint.sh` scripts and
`docker-compose.yml` configuration.


### Virtual Machines vs Docker

**Virtual Machine**: A fully isolated environment emulating a separate physical machine. Runs its own guest OS and kernel, provisioned and managed by a **hypervisor** (a software layer that virtualizes underlying hardware resources — CPU, memory, storage). Resource-intensive and slower to initialize, as each instance boots a complete OS.

**Docker**: A containerized environment that **shares the host's kernel** rather than running its own. Isolation is achieved via Linux kernel primitives such as **namespaces** (process, network, and filesystem isolation) and **cgroups** (resource allocation and limits). Lightweight and near-instantaneous to start, since no OS boot process is required.

**Summary:** VMs virtualize hardware and run an independent OS; containers virtualize at the OS level, sharing the host kernel while isolating processes.

### Secrets vs Environment Variables

Environment variables (using `environment:` or `.env`) get injected
directly into the container. They're visible with `docker inspect`
or `env`, so they work fine for non-sensitive config like
`DATABASE_NAME` or `DOMAIN_NAME`.

Docker secrets are different. They're mounted as files at
`/run/secrets/<name>`, and only when the container starts running,
never during the image build. They don't show up in `docker inspect`
or `env`, and since they're never baked into an image layer, they
can't be recovered later with `docker history`. That's the key
problem with hardcoding a password using `COPY` or `ENV` in a
Dockerfile: it stays in the image forever.

This project uses secrets for every password, and environment
variables for everything else.

### Docker Network vs Host Network

`network: host` removes network isolation completely. The container
just shares the host's network stack directly. The subject forbids
this.

A custom bridge network, which is what this project uses, keeps
containers isolated so only the ones attached to it can talk to each
other. It also gives automatic DNS resolution by service name, so
`mariadb` or `wordpress` can be used instead of hardcoded IPs. This
DNS resolution only works with a custom bridge network though, not
with Docker's default `bridge` network.

Only NGINX exposes a port to the host (443), which is what the
subject requires.

### Docker Volumes vs Bind Mounts

A bind mount connects a container path directly to a host path,
written inline under `service.volumes:`. Docker doesn't track it as
its own object, so it won't show up in `docker volume ls`.

A named volume is declared in the `volumes:` section, and
Docker creates and manages it (`docker volume create`,
`docker volume inspect`, `docker volume rm`). Services reference it
by name.

This project uses named volumes with `driver_opts`
(`type: none`, `o: bind`, `device:`) to meet both requirements at
once. They stay Docker managed named volumes, but their data still
lives at a specific host path, `/home/<login>/data/`. Even though
this uses a bind mechanism internally, it's still tracked by Docker,
so it's not the same as a raw bind mount.