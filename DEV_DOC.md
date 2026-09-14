# Developer Documentation

## Setting up the environment from scratch

### Prerequisites

- A Linux Virtual Machine (Debian or Alpine recommended).
- Docker Engine and the Docker Compose plugin installed.
- `make` installed.
- Root or sudo privileges.

Install Docker on Debian:

sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# then log out and back in

### Clone the repository

git clone <repository-url>
cd inception

### Configuration files

Create `srcs/.env` with the following variables:

DOMAIN_NAME=aelbouz.42.fr

MYSQL_ROOT_PASSWORD=<root-password>
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=<user-password>

WORDPRESS_ADMIN_USER=aelbouz
WORDPRESS_ADMIN_PASSWORD=<admin-password>
WORDPRESS_ADMIN_EMAIL=aelbouz@example.com

WORDPRESS_USER=regular_user
WORDPRESS_USER_PASSWORD=<user-password>
WORDPRESS_USER_EMAIL=user@example.com

Add `srcs/.env` to `.gitignore`.

### Secrets

All credentials live in `srcs/.env`. They are injected into the containers via `env_file: .env` in `docker-compose.yml`. No password is ever written in a Dockerfile.

### Local domain

Add to `/etc/hosts`:

127.0.0.1 aelbouz.42.fr

### Host data directories

sudo mkdir -p /home/aelbouz/data/db_data
sudo mkdir -p /home/aelbouz/data/wp_data
sudo chown -R $USER:$USER /home/aelbouz/data

---

## Building and launching with the Makefile

From the project root:

make

This runs:

docker compose -f srcs/docker-compose.yml up -d --build

Other Makefile targets:

- make up       — build images and start the stack.
- make down     — stop and remove containers (volumes preserved).
- make stop     — stop containers without removing them.
- make start    — start previously stopped containers.
- make ps       — show container status.
- make logs     — follow logs from all containers.
- make clean    — remove containers, images, networks, volumes.
- make fclean   — clean + prune + delete host data.
- make re       — full rebuild.

---

## Managing containers and volumes

### Containers

docker ps
docker ps -a
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker logs -f wordpress
docker restart nginx

### Volumes

docker volume ls
docker volume inspect db_data
docker volume inspect wp_data
docker volume rm db_data

### Network

docker network inspect inception_network
docker exec -it nginx ping wordpress
docker exec -it wordpress ping mariadb

---

## Where the project data is stored and how it persists

Two named volumes are used:

- `db_data` — mounted at `/var/lib/mysql` in the mariadb container, physically stored at `/home/aelbouz/data/db_data/` on the host.
- `wp_data` — mounted at `/var/www/html` in both the wordpress and nginx containers, physically stored at `/home/aelbouz/data/wp_data/` on the host.

Both are declared in `docker-compose.yml` with the `local` driver and `bind` options.

Persistence behaviour:

- `make down` keeps the volumes; `make up` reattaches to them and data is intact.
- `make fclean` removes the volumes and the host folders; all data is lost.

The `wp_data` volume is shared between WordPress and NGINX: WordPress writes files to it, NGINX reads files from it.
