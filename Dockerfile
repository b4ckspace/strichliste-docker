FROM composer:2.8.12 as phpcomposer

# ---

FROM dunglas/frankenphp:1.9.1-php8.4.12-trixie AS phpbuild

COPY --from=phpcomposer /usr/bin/composer /usr/bin/composer

RUN apt update
RUN apt install -y git unzip

ADD https://github.com/b4ckspace/strichliste-backend.git#php8.4 /app/backend
WORKDIR /app/backend

RUN composer install
RUN composer require runtime/frankenphp-symfony

# ---

FROM node:20.19.5-trixie AS jsbuild

ADD https://github.com/strichliste/strichliste-web-frontend.git#v1.7.1 /app/frontend
WORKDIR /app/frontend

RUN yarn install

ENV NODE_OPTIONS=--openssl-legacy-provider
RUN yarn build

# ---

FROM dunglas/frankenphp:1.9.1-php8.4.12-trixie AS docker

RUN install-php-extensions pdo_pgsql pdo_mysql mysqli bcmath imagick

COPY --from=phpbuild /app/backend /app
COPY --from=jsbuild /app/frontend/build /app/public

WORKDIR /app

ENV FRANKENPHP_CONFIG="worker ./public/index.php"
ENV APP_RUNTIME="Runtime\\FrankenPhpSymfony\\Runtime"
ENV APP_ENV=dev

# ---

FROM dunglas/frankenphp:static-builder-musl-1.9.1 AS static

COPY --from=docker /app /app

WORKDIR /go/src/app/
RUN NO_COMPRESS=1 EMBED=/app/ ./build-static.sh

# ---

FROM scratch

COPY --from=static /go/src/app/dist/frankenphp-linux-x86_64 /app

ENV FRANKENPHP_CONFIG="worker ./public/index.php"
ENV APP_RUNTIME="Runtime\\FrankenPhpSymfony\\Runtime"
ENV APP_ENV=dev
ENTRYPOINT ["/app", "php-server", "--listen", ":8080"]
