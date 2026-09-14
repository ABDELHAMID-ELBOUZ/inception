# User Documentation

## What services are provided by the stack

The Inception stack provides three services:

- **NGINX** — the web server and only entry point. It listens on port 443 with HTTPS (TLSv1.2 and TLSv1.3) and forwards PHP requests to WordPress.
- **WordPress + PHP-FPM** — the website application. It runs on port 9000 internally and connects to MariaDB for data.
- **MariaDB** — the database server. It stores all WordPress data (posts, users, settings) on port 3306 internally.

Only NGINX is reachable from outside the Docker network. The other two are internal.

---

## How to start the project

1. Open a terminal in the project root.
2. Run:

   make

3. Wait about 30 seconds for WordPress to install and MariaDB to initialize.

## How to stop the project

- To stop the containers without deleting data:

  make down

- To stop and remove containers, images, and volumes:

  make clean

- To stop and remove everything, including the host data:

  make fclean

- To rebuild from scratch:

  make re

---

## How to access the website

Open a browser and go to:

https://aelbouz.42.fr/

Because the certificate is self-signed, the browser will show a security warning. Accept it and continue to the site.

## How to access the administration panel

Go to:

https://aelbouz.42.fr/wp-admin

Log in with the administrator username and password stored in `srcs/.env` (see below). Once logged in, you can create posts, manage users, install plugins, and change site settings.

---

## How to locate and manage credentials

All credentials are stored in the file:

srcs/.env

This file is listed in `.gitignore` and must never be committed. It contains:

- `MYSQL_ROOT_PASSWORD` — root password for MariaDB.
- `MYSQL_DATABASE` — name of the WordPress database.
- `MYSQL_USER` and `MYSQL_PASSWORD` — credentials WordPress uses to connect to the database.
- `WORDPRESS_ADMIN_USER`, `WORDPRESS_ADMIN_PASSWORD`, `WORDPRESS_ADMIN_EMAIL` — the WordPress administrator account.
- `WORDPRESS_USER`, `WORDPRESS_USER_PASSWORD`, `WORDPRESS_USER_EMAIL` — the second WordPress user.

To change a credential, edit `srcs/.env` and rebuild with:

make fclean
make

Note: rebuilding erases existing data.

---

## How to check that services are running correctly

### Quick check

make ps

All three containers should show status `Up`.

### Logs

- All services:  make logs
- One service:   docker logs mariadb
                 docker logs wordpress
                 docker logs nginx

### Web server

curl -k -I https://aelbouz.42.fr/

Should return `HTTP/1.1 200 OK`.

### Database

docker exec -it mariadb mysql -u wp_user -p -e "SHOW DATABASES;"

Enter the `MYSQL_PASSWORD` when prompted. The `wordpress` database should be listed.
