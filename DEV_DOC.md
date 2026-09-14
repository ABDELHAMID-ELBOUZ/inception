# Developer Documentation

This document explains how a developer can set up, build, and manage the Inception project from scratch.

## 1. Prerequisites

- Linux VM (Debian or Alpine)
- Docker Engine (latest)
- Docker Compose v2+
- make
- OpenSSL

Install Docker on Debian:

    sudo apt update
    sudo apt install -y docker.io docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER   # then log out and back in

## 2. Environment Setup

### a. Clone the repository

    git clone <repo-url>
    cd inception

### b. Create the .env file

Create srcs/.env with: DOMAIN_NAME, MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, WORDPRESS_ADMIN_USER, WORDPRESS_ADMIN_PASSWORD, WORDPRESS_ADMIN_EMAIL, WORDPRESS_USER, WORDPRESS_USER_PASSWORD, WORDPRESS_USER_EMAIL.

Rules:
- WORDPRESS_ADMIN_USER must not contain "admin".
- .env must be in .gitignore.
- No passwords in any Dockerfile.

### c. Configure the local domain

Add to /etc/hosts: 127.0.0.1 aelbouz.42.fr

### d. Create host data directories

    sudo mkdir -p /home/aelbouz/data/db_data
    sudo mkdir -p /home/aelbouz/data/wp_data
    sudo chown -R $USER:$USER /home/aelbouz/data

## 3. Directory Structure

inception/
- Makefile, README.md, USER_DOC.md, DEV_DOC.md, .gitignore
- srcs/
  - docker-compose.yml, .env
  - requirements/
    - nginx/Dockerfile, nginx/conf/nginx.conf
    - wordpress/Dockerfile, wordpress/tools/entrypoint.sh
    - mariadb/Dockerfile, mariadb/conf/my.cnf, mariadb/tools/entrypoint.sh

## 4. Build and Launch

- make         # build + start
- make up      # same as make
- make down    # stop + remove containers, volumes preserved
- make stop    # stop containers
- make start   # start stopped containers
- make ps      # status
- make logs    # follow logs
- make clean   # remove containers, images, networks, volumes
- make fclean  # clean + prune + delete host data
- make re      # full rebuild

First-time build: make

Under the hood: docker compose -f srcs/docker-compose.yml up -d --build

Verify:
- docker images   → nginx, wordpress, mariadb
- docker volume ls → db_data, wp_data
- docker network ls | grep inception_network

## 5. Managing Containers and Volumes

Containers: docker ps, docker ps -a, docker exec -it <name> bash, docker logs -f <name>, docker restart <name>

Volumes: docker volume ls, docker volume inspect db_data, docker volume rm db_data

Network: docker network inspect inception_network, docker exec -it nginx ping wordpress

## 6. Where data is stored and how it persists

- db_data: /home/aelbouz/data/db_data → /var/lib/mysql
- wp_data: /home/aelbouz/data/wp_data → /var/www/html

Both volumes use local driver with bind options. Persistence:
- make down → volumes kept
- make up → data intact
- make fclean → data destroyed

wp_data is shared between WordPress and NGINX containers.

## 7. Rebuilding after a change

- Dockerfile         → make
- docker-compose.yml → make down && make
- NGINX config       → docker restart nginx
- MariaDB my.cnf     → make re
- WordPress entrypoint → make
- .env               → make fclean && make

## 8. Debugging Tips

- Container won't start: docker logs <name>, docker inspect <name>
- Inspect container: docker exec -it <name> env / ls -la / / ps -o pid,cmd
- Volume check: docker volume inspect db_data
- NGINX check: docker exec -it nginx nginx -t / nginx -T
- PHP-FPM check: docker exec -it wordpress ps aux | grep php-fpm
- MariaDB check: docker exec -it mariadb mysqladmin ping -u root -p

## 9. Security Checklist

- .env in .gitignore
- No hardcoded passwords
- TLS 1.2/1.3 only
- Only NGINX exposes a port
- No network: host or --link
- No tail -f, sleep infinity, while true
- PID 1 is the daemon

## 10. Full Rebuild Procedure

    make fclean
    make
    sleep 30
    make ps
    curl -k -I https://aelbouz.42.fr/
    docker logs wordpress | grep "installation complete"

## 11. Known Constraints (from the subject)

Forbidden: network: host, --link, links:, tail -f, bash, sleep infinity, while true, latest tag, hardcoded passwords, pre-built images (other than Alpine/Debian base), bind mounts for the two volumes.