# User Documentation — Inception

This document explains how to use, operate, and monitor the Inception infrastructure as an end user or administrator.

---

## Services Provided by the Stack

The Inception stack runs three services, each in its own Docker container:

| Service | Container Name | Description |
|---------|---------------|-------------|
| **NGINX** | `nginx` | Reverse proxy and sole entry point to the infrastructure. Handles HTTPS (TLSv1.2/TLSv1.3 only) and forwards requests to WordPress. |
| **WordPress + PHP-FPM** | `wordpress` | The web application. Runs WordPress via PHP-FPM on port 9000. Not directly exposed to the outside — only accessible through NGINX. |
| **MariaDB** | `mariadb` | The relational database. Stores all WordPress content, users, and settings. Not exposed outside the internal Docker network. |

---

## Starting and Stopping the Project

### Start the project

From the root of the repository:

```bash
make
```

This command builds all Docker images (if not already built) and starts all containers in the background. On subsequent runs, if images are already built, you can also use:

```bash
make up
```

### Stop the project

To stop all containers without removing them:

```bash
make down
```

To stop containers and remove all images and volumes:

```bash
make clean
```

To perform a **full reset** (containers, images, volumes and cache):

```bash
make fclean
```

---

## Accessing the Website and Administration Panel

### Website

The WordPress site is available at:

```
https://malapoug.42.fr
```

> If you are not on the 42 network and have not configured DNS, add the following line to your `/etc/hosts` file:
> ```
> 127.0.0.1   malapoug.42.fr
> ```

The site uses a self-signed TLS certificate. Your browser will show a security warning — this is expected. Accept the exception to proceed.

### WordPress Administration Panel

The admin dashboard is accessible at:

```
https://malapoug.42.fr/wp-admin
```

Log in with the WordPress admin credentials (see the section below for how to find them).

---

## Locating and Managing Credentials

All credentials are stored in a **.env** file — plain text files in the `srcs/.env` directory. These files are never committed to the Git repository.

### Changing a credential

1. Edit the relevant file in `srcs/.env`, there is a base file in `/srcs/.env.base`.
2. Make sure to fill every informations listed.
2. Rebuild and restart the affected containers:

```bash
make re
```

> Changing the database password after the database has already been initialized requires manually updating the MariaDB user as well. See [DEV_DOC.md](DEV_DOC.md) for details.

---

## Checking That Services Are Running Correctly

### View running containers

```bash
make ps
# or
docker compose -f srcs/docker-compose.yml ps
```

All three containers (`nginx`, `wordpress`, `mariadb`) should show a `running` or `Up` status.

### View live logs

```bash
make logs
# or
docker compose -f srcs/docker-compose.yml logs -f
```

To view logs for a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

### Test NGINX and HTTPS

```bash
curl -k https://malapoug.42.fr
```

A successful response returns the WordPress HTML. The `-k` flag skips certificate validation for self-signed certs.

### Test the database connection

```bash
docker exec -it mariadb mariadb -u wp_user -p
```

Once connected, verify the WordPress database exists:

```sql
SHOW DATABASES;
```

### Quick health check

```bash
# Check NGINX is responding
curl -kI https://malapoug.42.fr

# Check WordPress process is running
docker exec wordpress pgrep php-fpm

# Check MariaDB is accepting connections
docker exec mariadb mariadb-admin -u root -p<db_root_password> ping
```
