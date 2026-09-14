*This project has been created as part of the 42 curriculum by aelbouz.*

# Inception

## Description

**Inception** is a system administration project from the 42 curriculum. Its goal is to build a small, self-contained web infrastructure using **Docker** and **Docker Compose**, running entirely inside a Virtual Machine.

The stack is composed of three independent services, each running in its own container, built from a custom Dockerfile:

- **NGINX** — the only entry point into the infrastructure, serving HTTPS on port 443 with TLSv1.2 and TLSv1.3 only.
- **WordPress + PHP-FPM** — the application layer, running WordPress with PHP-FPM (without a web server).
- **MariaDB** — the database layer, storing all WordPress data.

The whole project is orchestrated by a **Makefile** and a `docker-compose.yml` file. Two **named Docker volumes** persist the WordPress files and the database, both stored on the host at `/home/aelbouz/data/`.

---

## Instructions

### Prerequisites

- A Linux Virtual Machine (Debian or Alpine recommended).
- Docker Engine and the Docker Compose plugin installed.
- Root or sudo privileges.
- `make` installed.

### Setup

1. Clone the repository and enter it.

2. Create the `.env` file inside `srcs/` with all required variables (domain, MariaDB credentials, WordPress admin and user credentials).

3. Add `127.0.0.1 aelbouz.42.fr` to `/etc/hosts`.

4. Create the host data directories `/home/aelbouz/data/db_data` and `/home/aelbouz/data/wp_data`.

### Build and run

From the root of the repository:

    make

### Access

Open a browser and go to:

    https://aelbouz.42.fr/

Accept the self-signed certificate warning.

### Stop and clean

    make down     # Stop and remove containers (data persists)
    make clean    # Also remove images, networks, and volumes
    make fclean   # Full reset — removes everything, including /home/aelbouz/data
    make re       # Full rebuild (fclean + up)

---

## Project Description

### Use of Docker and Sources Included in the Project

Docker is a containerization platform that packages an application and all its dependencies into a single image that can be run anywhere Docker is installed. Unlike virtual machines, containers share the host kernel — they are lighter, faster to start, and more resource-efficient. For this project, Docker isolates each service (web, application, database) in its own container, communicating over a private network, without installing anything permanently on the host.

The sources included in the project are:

- Dockerfiles for each service — instructions to build custom images.
- docker-compose.yml — orchestrates the three services, the network, and the volumes.
- Makefile — wraps Docker Compose commands for convenience.
- Configuration files — nginx.conf, my.cnf, PHP-FPM pool configuration.
- Entrypoint scripts — runtime initialization logic for each container.

No pre-built images from Docker Hub (other than the official Debian base image) are used.

### Main Design Choices

1. Base image: Debian (penultimate stable release). Debian was chosen over Alpine for its broader package availability and better compatibility with MariaDB and PHP-FPM.
2. TLS: Only TLSv1.2 and TLSv1.3 are enabled in NGINX, per the subject.
3. Volumes: Two named volumes are used (db_data, wp_data) with the local driver and bind options to physically store data under /home/aelbouz/data/ on the host.
4. Network: A custom bridge network (inception_network) connects the three containers. Host networking and --link are strictly avoided.
5. Secrets: Credentials are kept in a .env file (never committed) and injected via environment variables.
6. PID 1: Each container runs its daemon directly (nginx, php-fpm8.2 -F, mysqld) via exec, so no shell or infinite-loop hack keeps the container alive.

### Comparisons

#### Virtual Machines vs Docker

| Aspect | Virtual Machine | Docker Container |
|--------|-----------------|------------------|
| Isolation | Full — separate OS kernel | Process-level — shares host kernel |
| Size | Gigabytes | Megabytes |
| Boot time | Minutes | Seconds |
| Resource usage | High | Low |
| Portability | Less portable | Highly portable |
| Use case | Strong isolation, multi-OS | Microservices, fast deployment |

The project requires lightweight, reproducible services with fast startup. A VM would be overkill for a three-service stack and much heavier.

#### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|----------------|
| Storage | Plain text in .env or shell | Stored in Docker's secure store |
| Access | Any process in the container can read | Mounted as files, readable only by the intended user |
| Visibility | Visible in docker inspect and ps | Not visible in docker inspect |
| Git risk | Often accidentally committed | Not stored in Git |
| Complexity | Simple | Requires Swarm mode or manual file mounting |

The subject permits (and even encourages) .env files as long as they are not committed to Git. The project scope is small enough that Docker secrets would add unnecessary complexity.

#### Docker Network vs Host Network

| Aspect | Docker Network (bridge) | Host Network |
|--------|------------------------|--------------|
| Isolation | Containers have their own IPs | Containers share the host's network stack |
| Port conflicts | None — internal IPs | All containers share the host's ports |
| DNS resolution | Service names resolve automatically | Manual configuration |
| Security | Isolated from host by default | Containers can access all host ports |
| Portability | Works everywhere | Tied to the host's network config |

The subject explicitly forbids network: host. A custom bridge network gives containers their own isolated space, with automatic DNS resolution, and only NGINX is exposed to the host on port 443.

#### Docker Volumes vs Bind Mounts

| Aspect | Named Volume | Bind Mount |
|--------|--------------|------------|
| Managed by | Docker | Host filesystem |
| Location | /var/lib/docker/volumes/... | Any path on the host |
| Portability | High — Docker manages them | Path-dependent |
| Backup | Via docker volume commands | Direct filesystem access |
| Use case | Persistent app data | Config files, source code |

The subject explicitly forbids bind mounts for persistent storage and requires named volumes. Our volumes use the local driver with bind options — so they are named (created and managed by Docker) but physically store data under /home/aelbouz/data/ on the host, as required by the subject.

---

## Resources

### Official Documentation

- Docker Documentation: https://docs.docker.com/
- Docker Compose File Reference: https://docs.docker.com/compose/compose-file/
- NGINX Documentation: https://nginx.org/en/docs/
- WordPress Documentation: https://wordpress.org/documentation/
- WP-CLI Handbook: https://make.wordpress.org/cli/handbook/
- MariaDB Documentation: https://mariadb.com/kb/en/documentation/
- PHP-FPM Documentation: https://www.php.net/manual/en/install.fpm.php

### Articles & Tutorials

- Docker Official Get Started Guide: https://docs.docker.com/get-started/
- NGINX Beginner's Guide: https://nginx.org/en/docs/beginners_guide.html
- Understanding Docker Networking: https://docs.docker.com/network/
- Understanding Docker Volumes: https://docs.docker.com/storage/volumes/
- The Twelve-Factor App — Config: https://12factor.net/config

### AI Usage

AI (Claude, ChatGPT) was used as a learning and debugging tool, never as a code-generation shortcut. Specifically:

- Understanding concepts: AI was used to explain Docker internals (PID 1, signal handling, ENTRYPOINT vs CMD), NGINX directive semantics, TLS handshake details, and the MariaDB initialization flow.
- Debugging: AI helped diagnose and fix several build and runtime errors: the MariaDB socket error, Debian APT 404 errors during image build, TLS configuration confusion, and WordPress database connection issues on startup.
- Configuration review: AI was used to review nginx.conf, my.cnf, docker-compose.yml, and the entrypoint scripts for correctness and compliance with the subject.
- Documentation: AI assisted in drafting the structure of this README and the other documentation files.

Every AI-generated suggestion was read, discussed with peers, and tested manually. Every line of the final code is understood and can be justified during evaluation.

---

## Author

aelbouz — 42 student.
