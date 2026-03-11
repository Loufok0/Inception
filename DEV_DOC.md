# Developer Documentation — Inception

This document describes how to set up, build, and manage the Inception infrastructure from a developer's perspective.

---

## Setting Up the Environment from Scratch

### Prerequisites

Ensure the following tools are installed on your system (or VM):

| Tool | Minimum Version | Check |
|------|----------------|-------|
| Docker Engine | 20.10+ | `docker --version` |
| Docker Compose | 2.0+ (plugin) | `docker compose version` |
| make | Any | `make --version` |
| git | Any | `git --version` |

> The project is designed to run on **Linux** (Debian or Alpine-based). It is typically run inside a VM as required by the 42 subject.

### 1. Clone the Repository

```bash
git clone https://github.com/Loufok0/Inception.git
cd Inception
```

### 2. Configure the Environment File

Copy the example environment file and fill in your values:

```bash
cp srcs/.env.example srcs/.env
```

Edit `srcs/.env` with your own informations

### 3. Configure `/etc/hosts` (won't work on 42 network)

```bash
echo "127.0.0.1   loufok0.42.fr" | sudo tee -a /etc/hosts
```

---

## Building and Launching the Project

### Using the Makefile

The `Makefile` at the root is the primary interface for managing the project.

| Target | Description |
|--------|-------------|
| `make` | Create data directories and build images, then start all containers in detached mode |
| `make up` | Start all containers in the foreground (without rebuilding) |
| `make down` | Stop and remove containers |
| `make clean` | Stop and remove containers and volumes |
| `make fclean` | `clean` + remove all unused Docker images, containers, networks and cache |
| `make re` | `fclean` + full rebuild |
| `make ps` | Show running containers for this Compose project |
| `make volume-ls` | List all Docker volumes on the system |
| `make logs` | Tail logs from all containers |
---

## Managing Containers and Volumes

### Inspecting Containers

```bash
# List all containers (running and stopped)
make ps

# View detailed info about a container
docker inspect <container-name>

# Open a shell inside a running container
docker exec -it nginx sh
docker exec -it wordpress bash
docker exec -it mariadb bash
```

### Viewing Logs

```bash
# All services
make logs

# Single service
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

### Managing Volumes

```bash
# List all Docker volumes
docker volume ls

# Inspect a volume (shows mountpoint on host)
docker volume inspect srcs_wordpress_data
docker volume inspect srcs_mariadb_data

# Remove a specific volume (container must be stopped first)
docker volume rm srcs_mariadb_data
```

> ⚠️ Removing a volume permanently deletes all data stored in it.

### Rebuilding a Single Service

```bash
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml up -d --no-deps wordpress
```

### Resetting the Database

If you need to reset MariaDB to a clean state:

```bash
make down
sudo rm -rf ~/data/malapoug/mariadb/*
make up
```

---

## Data Storage and Persistence

### Where Data Lives

All persistent data is stored on the host machine using **bind mounts**, mapped from inside the containers to the following host paths:

| Service | Host Path | Container Path | Contents |
|---------|-----------|----------------|----------|
| WordPress | `~/malapoug/data/wordpress` | `/var/www/html` | WordPress core files, themes, plugins, uploads |
| MariaDB | `~/malapoug/data/mariadb` | `/var/lib/mysql` | Database files, tables, and indexes |

### How Persistence Works

Data in these directories **survives** container restarts and `make down`. It is only deleted by:
- Running `make fclean` (which removes `~/nalapoug/data/`)
- Manually deleting the directories with `rm -rf ~/malapoug/data/`

### Backup

To back up your data, simply copy the host directories:

```bash
mkdir -p ~/malapoug/backup/wordpress/
mkdir -p ~/malapoug/backup/mariadb/
cp -r ~/malapoug/data/wordpress ~/malapoug/backup/wordpress/wordpress_$(date +%F)
cp -r ~/malapoug/data/mariadb ~/malapoug/backup/mariadb/mariadb_$(date +%F)
```

### Volume Definitions in Compose

```yaml
volumes:
  wordpress:
    driver: local
    driver_opts:
      device: /home/malapoug/data/wordpress
      o: bind
      type: none

  mariadb:
    driver: local
    driver_opts:
      device: /home/malapoug/data/mariadb
      o: bind
      type: none
```

---

## Project Structure

```
Inception/
├── README.md
├── DEV_DOC.md
├── DEV_DOC.md
├── Makefile
├── srcs
    ├── .env                      # Environment variables (not committed)
    ├── .env.base                 # Template for .env
    ├── docker-compose.yml        # Compose file defining all services
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   ├── conf
        │   │   └── 50-server.cnf
        │   └── tools
        │       └── mariadb-setup.sh
        ├── nginx
        │   ├── Dockerfile
        │   └── conf
        │       └── nginx.conf
        └── wordpress
            ├── Dockerfile
            ├── conf
            │   ├── wp-config.php
            │   └── www.conf
            └── tools
                └── wp-conf.sh
```

---

## Common Issues

### Containers exit immediately on startup

### NGINX shows `502 Bad Gateway`

WordPress (PHP-FPM) is not yet ready. Wait a few seconds and refresh, or check:
```bash
docker compose -f srcs/docker-compose.yml logs wordpress
```

### Database connection refused

MariaDB may still be initializing. Check logs:
```bash
docker compose -f srcs/docker-compose.yml logs mariadb
```
If the data directory is corrupt, reset it:
```bash
make re
```

