# Strichliste docker container setup

This is a docker container setup for strichliste. It uses a slightly patched
version of the backend to ensure php8.4 and frankenphp compability.

It's currently in use at the hackerspace bamberg.

We use our own `docker-compose.yaml` and `.env` files for our infrastructure.
Please make sure to update both for your needs.

## Quickstart

These commands should get you up and running.

```
# start
docker compose up -d

# only needed on first start
docker compose exec strichliste /app php-cli bin/console doctrine:schema:create
```
