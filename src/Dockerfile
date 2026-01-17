# Lane4 Digital PHP CLI – Multi-Stage
#
# Build-time ARGs: Provided by docker-compose.yml or Makefile from .env
# Runtime config: Fixed defaults below, override with docker run -e VAR=value
#
ARG ALPINE_VERSION
ARG PHP_VERSION

# PECL Extension Versions (build-time only)
ARG APCU_VERSION
ARG REDIS_VERSION
ARG XDEBUG_VERSION
ARG PCOV_VERSION
ARG AMQP_VERSION
ARG RDKAFKA_VERSION

# Build-time options
ARG INSTALL_DB_CLIENTS
ARG PUID
ARG PGID

ARG COMPOSER_VERSION=2.9.3
FROM composer:${COMPOSER_VERSION} AS composer

# --------------------
# Build stage
# --------------------
FROM php:${PHP_VERSION}-cli-alpine${ALPINE_VERSION} AS build
LABEL maintainer="HeadgentOps <devops@headgent.dev>"

ARG APCU_VERSION
ARG REDIS_VERSION
ARG XDEBUG_VERSION
ARG PCOV_VERSION
ARG AMQP_VERSION
ARG RDKAFKA_VERSION

RUN apk upgrade --no-cache && apk add --no-cache \
      autoconf make g++ gcc libc-dev linux-headers libzip-dev libxml2-dev oniguruma-dev icu-dev curl-dev \
      libjpeg-turbo-dev libpng-dev freetype-dev pcre2-dev re2c pkgconf flex bison libxslt-dev python3 perl gperf \
      gawk sed grep findutils coreutils postgresql-dev \
      rabbitmq-c-dev librdkafka-dev \
 && export LC_ALL=C \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" curl soap zip mbstring intl bcmath gd sockets exif pcntl pdo_mysql mysqli pdo_pgsql \
 && docker-php-ext-install -j1 dom \
 && pecl channel-update pecl.php.net \
 && pecl config-set preferred_state stable \
 && yes "" | pecl install -o -f \
      apcu-${APCU_VERSION} \
      redis-${REDIS_VERSION} \
      xdebug-${XDEBUG_VERSION} \
      pcov-${PCOV_VERSION} \
      amqp-${AMQP_VERSION} \
      rdkafka-${RDKAFKA_VERSION} \
 && docker-php-ext-enable apcu redis xdebug pcov amqp rdkafka \
 && docker-php-ext-enable opcache

# --------------------
# Runtime stage
# --------------------
FROM php:${PHP_VERSION}-cli-alpine${ALPINE_VERSION}
LABEL maintainer="HeadgentOps <devops@headgent.dev>"

# Build-time ARGs for this stage
ARG INSTALL_DB_CLIENTS
ARG PUID
ARG PGID

# Runtime configuration - override with: docker run -e VAR=value
ENV PHP_MEMORY_LIMIT=512M \
    PHP_MAX_EXECUTION_TIME=0 \
    PHP_TIMEZONE=UTC \
    APCU_SHM_SIZE=64M \
    OPCACHE_MEMORY_CONSUMPTION=128 \
    OPCACHE_MAX_ACCELERATED_FILES=4000 \
    OPCACHE_REVALIDATE_FREQ=2 \
    OPCACHE_JIT=1254 \
    OPCACHE_JIT_BUFFER_SIZE=128M \
    PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT" \
    PHP_DISPLAY_ERRORS=Off \
    PHP_LOG_ERRORS=On \
    XDEBUG_MODE=debug \
    XDEBUG_START_WITH_REQUEST=yes \
    XDEBUG_CLIENT_HOST=host.docker.internal \
    XDEBUG_CLIENT_PORT=9003 \
    XDEBUG_LOG_LEVEL=0 \
    PCOV_ENABLED=0

# Runtime-Libs + optional DB clients (INSTALL_DB_CLIENTS=mysql,postgres,sqlite)
# NOTE: unzip removed - Composer uses PHP's ZipArchive extension (ext-zip) instead
RUN set -eux; \
    apk upgrade --no-cache && \
    PKGS="bash git icu-libs libzip libxml2 oniguruma libjpeg-turbo libpng freetype postgresql-libs rabbitmq-c librdkafka"; \
    case ",${INSTALL_DB_CLIENTS}," in *,mysql,*) PKGS="$PKGS mysql-client";; esac; \
    case ",${INSTALL_DB_CLIENTS}," in *,postgres,*) PKGS="$PKGS postgresql-client";; esac; \
    case ",${INSTALL_DB_CLIENTS}," in *,sqlite,*) PKGS="$PKGS sqlite";; esac; \
    apk add --no-cache $PKGS && \
    rm -rf /var/cache/apk/* /tmp/* && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# Composer - pinned version for reproducible builds and security
# Update: check https://github.com/composer/composer/releases
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# Gebaute Extensions & INIs übernehmen
COPY --from=build /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=build /usr/local/etc/php/conf.d/   /usr/local/etc/php/conf.d/

# OPcache-Ini früh laden (falls vorhanden)
RUN if [ -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini ]; then \
      mv /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/00-opcache.ini; \
    fi

# Konfiguration & Entrypoint
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Non-root user & runtime-config symlink
RUN addgroup -g ${PGID} appgroup \
 && adduser -G appgroup -u ${PUID} -D -s /bin/bash appuser \
 && mkdir -p /app /home/appuser/php-config \
 && chown -R appuser:appgroup /app /home/appuser \
 && : > /home/appuser/php-config/99-runtime-config.ini \
 && chown appuser:appgroup /home/appuser/php-config/99-runtime-config.ini \
 && ln -sf /home/appuser/php-config/99-runtime-config.ini /usr/local/etc/php/conf.d/99-runtime-config.ini

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD sh -c "php --version >/dev/null && composer --version >/dev/null"

USER appuser
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php","--version"]
