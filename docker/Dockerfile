# docker build --pull --tag docker-ui --build-arg BUILDKIT_INLINE_CACHE=1 --file ./docker/Dockerfile ./ && docker run -it --rm docker-ui
FROM node:4-alpine as node

WORKDIR /tmp/
ENV NODE_ENV=production
ENV NPM_CONFIG_UNSAFE_PERM=true


# Core utilites install
RUN set -eux \
  && apk add --quiet --update --no-cache \
    unzip \
    curl \
    git

RUN set -eux \
    && curl -fsSL https://github.com/phplegacy/gearman-ui/archive/master.zip --output /tmp/gearmand.zip \
    && unzip -uoq /tmp/gearmand.zip -d /tmp/ \
    && cd /tmp/gearman-ui-master/ \
    && npm install -g bower \
    && bower install --production --allow-root --silent


FROM php:8.2-fpm-alpine as php

ENV TERM="xterm-256color" \
LANGUAGE="en_US.UTF-8" \
LANG="en_US.UTF-8" \
LC_TIME="en_DK.UTF-8" \
TIME_STYLE="long-iso"

WORKDIR /app/

# Core utilites install
RUN set -eux \
  && apk add --quiet --update --no-cache \
    libcap \
    tzdata \
    git \
    # `fcgi` - Healthcheck |  https://github.com/renatomefi/php-fpm-healthcheck
    fcgi \
    # `tini` - https://github.com/krallin/tini
    tini \
    supervisor

# Easily install PHP extension in Docker containers | https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/install-php-extensions
RUN set -eux \
    && IPE_GD_WITHOUTAVIF=1 install-php-extensions \
        @composer-2 \
        opcache

# Healthcheck |  https://github.com/renatomefi/php-fpm-healthcheck
RUN set -eux \
    && curl -fsSL https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck --output /usr/local/bin/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck \
    && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf
HEALTHCHECK --start-period=30s CMD php-fpm-healthcheck || exit 1

# Caddy | https://caddyserver.com/
COPY --from=caddy:2-alpine /usr/bin/caddy /usr/local/bin/caddy
COPY ./docker/config/caddy/Caddyfile /etc/caddy/Caddyfile
RUN set -eux \
    && setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy \
    && caddy fmt --overwrite /etc/caddy/Caddyfile \
    && caddy version

RUN set -eux && cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
COPY ./docker/config/php/zzz-php_dev_custom.ini /usr/local/etc/php/conf.d/zzz-php_dev_custom.ini
COPY ./docker/config/php/php-fpm.d/zzz-php-fpm_dev_custom.conf /usr/local/etc/php-fpm.d/zzz-php-fpm_custom.conf
COPY ./docker/config/supervisor/supervisord.conf /etc/supervisord.conf

# Making new local user
ARG APP_UID=1000
ARG APP_GID=1000
RUN set -eux \
    && addgroup -g $APP_GID user && adduser -D -G user -u $APP_UID user
# environment
ENV HOME /home/user
ENV PATH ${PATH}:${HOME}/.composer/vendor/bin:/app/vendor/bin/

ENV COMPOSER_ALLOW_SUPERUSER=1

LABEL org.opencontainers.image.title="Gearman UI Docker image" \
    org.opencontainers.image.description="phplegacy Gearman UI Docker image" \
    org.opencontainers.image.authors="https://github.com/phplegacy/gearman-ui-docker" \
    org.opencontainers.image.documentation="https://github.com/phplegacy/gearman-ui-docker" \
    org.opencontainers.image.url="https://github.com/phplegacy/gearman-ui-docker" \
    org.opencontainers.image.source="https://github.com/phplegacy/gearman-ui-docker"

ARG TZ='UTC'
ENV TZ=$TZ

#These params meant to be set by CI
ARG BUILD_DATE
ENV BUILD_DATE=$BUILD_DATE
RUN echo $BUILD_DATE
ARG BUILD_FINGERPRINT
ENV BUILD_FINGERPRINT=$BUILD_FINGERPRINT
RUN echo $BUILD_FINGERPRINT

COPY --from=node /tmp/gearman-ui-master/ /app/
COPY ./docker/config/gearmanui/config.yml /app/config.yml
RUN set -eux \
    && composer install --prefer-dist --no-interaction --no-dev --optimize-autoloader --no-progress \
    && chown user:user -R /app/ \
    && apk del git --quiet

# entrypoint init
COPY --chmod=0755 ./docker/etc/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

USER user

CMD ["supervisor"]
EXPOSE 80
