*This project has been created as part of the 42 curriculum by malapoug.*

---

# Inception

## Description

Inception is a system administration project centered around Docker and containerization. The goal is to build a small but fully functional infrastructure composed of multiple services, each running in its own dedicated Docker container — all orchestrated with Docker Compose and launched from a single `Makefile`.

The stack includes:
- **NGINX** — the only entry point to the infrastructure, configured with TLSv1.2/TLSv1.3 only
- **WordPress** — a PHP-FPM application serving the website
- **MariaDB** — the relational database backend for WordPress

All containers are built from their own custom `Dockerfile` using either Alpine Linux or Debian (penultimate stable release), without pulling pre-built images from Docker Hub (except the base OS images).

Data is persisted using Docker volumes and the whole infrastructure runs on a custom Docker network with no `--network=host` or `--link` usage as it is unsafe and deprecated respectively.

---

## Instructions

### Prerequisites

- Docker Engine (here it is Docker version 29.1.5, build 0e6fee6)
- Docker Compose (here it is Docker Compose version 5.0.2)
- `make`

### Setup

1. Clone the repository:

```bash
git clone https://github.com/Loufok0/Inception.git
cd Inception
```

2. Configure your environment and secrets (see [DEV_DOC.md](DEV_DOC.md) for full details):

```bash
cp srcs/.env.example srcs/.env
# Edit srcs/.env with your domain and settings
```

3. Build and start the infrastructure:

```bash
make
```

4. Access the site at `https://malapoug.42.fr` (you may need to add this to `/etc/hosts`).

### Makefile Targets
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

## Project Description

### Docker Usage and Included Sources

This project uses Docker to package and isolate each service into its own container. All images are built from custom `Dockerfile`s located in `srcs/requirements/`. No pre-made images are used for the application services — only official base OS image (`debian`).

The `docker-compose.yml` file in `srcs/` defines all services, volumes, networks, and secrets. Environment variables are loaded from a `.env` file.

**Included services:**
- `nginx` — Reverse proxy and TLS termination
- `wordpress` — PHP-FPM process for the WordPress application
- `mariadb` — Database server

**Volume data** is stored on the host under `~/malapoug/data/` ensuring data persists across container restarts.

---

### Design Choices

- **No `latest` tags** — all base images pin a specific version to ensure reproducibility.
- **Passwords in environment files** — Easy to set up and use.
- **PID 1 safety** — each container runs its main process directly (not via shell wrappers) to properly handle signals and avoid zombie processes.
- **Restart policy** — all containers use `restart: unless-stopped` or `restart: on-failure` to recover from crashes automatically.
- **Non-root users** — where possible, services run as a dedicated non-root user inside the container.

---

### Virtual Machines vs Docker

| Aspect | Virtual Machine | Docker Container |
|--------|----------------|-----------------|
| Isolation | Full OS virtualization (hardware-level via hypervisor) | OS-level isolation (shared kernel) |
| Resource usage | Heavy — each VM includes a full OS | Lightweight — shares the host kernel |
| Boot time | Minutes | Seconds |
| Portability | Large VM images, harder to distribute | Small layered images, push/pull from registries |
| Use case | Running different OSes, strong isolation | Packaging and deploying individual services |

Docker is ideal for this project because each service (NGINX, WordPress, MariaDB) is a single, well-defined process that benefits from isolation without the overhead of a full VM.

---

### Docker Network vs Host Network

| Aspect | Custom Bridge Network | Host Network |
|--------|-----------------------|--------------|
| Isolation | Containers are isolated; communicate via service names | Container shares the host's network namespace |
| Port mapping | Requires explicit `ports:` declarations | No port mapping — uses host ports directly |
| Security | Better isolation between containers and host | No isolation — any port opened is exposed on the host |
| DNS | Built-in DNS resolution by container name | Must use `localhost` or IP |

This project uses a custom bridge network (`inception`) so containers can communicate securely by name (e.g., `wordpress` → `mariadb`) without exposing internal ports to the host.

---

### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|---------------|-------------|
| Location | Managed by Docker (`/var/lib/docker/volumes/`) | Explicit path on the host filesystem |
| Portability | Portable across systems | Host-path dependent |
| Performance | Optimized by Docker | Equivalent on Linux |
| Backup | Managed with `docker volume` commands | Standard filesystem tools |
| Use case | Production data persistence | Development (live code reloading), specific host paths |

This project uses **bind mounts** with specific host paths (`~/data/malapoug/wordpress` and `~/data/malapoug/mariadb`) as required by the subject, so data is explicitly located on the host VM and easy to inspect.

---

## Resources

### Docker & Containerization
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### NGINX
- [NGINX beginner's guide](https://nginx.org/en/docs/beginners_guide.html)
- [Configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html)

### WordPress & PHP-FPM
- [WordPress CLI documentation](https://developer.wordpress.org/cli/commands/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

### MariaDB
- [MariaDB Docker image documentation](https://hub.docker.com/_/mariadb)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

### AI Usage
AI (Claude by Anthropic) was used during this project for the following tasks:

- **Debugging Dockerfile issues** — as learning a new syntaxe/config file I've run into some issue, that I sometimes did not found response online.
- **Nginx configuration** — same, as learning a new syntax, I sometime had to ask for explanations as I didn't undestand documentation really well.
- **README and documentation** — made it prettier ✨
- **Comparisons and explanations** — clarifying Docker concepts (volumes, networks, secrets) for the documentation

AI was not used to write the core infrastructure code or Dockerfiles from scratch — all configuration decisions were made and validated manually.
