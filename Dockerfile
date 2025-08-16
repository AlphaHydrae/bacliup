FROM alpine:3.22.1 AS builder

RUN addgroup -S bacliup && \
    adduser -D -G bacliup -h /bacliup -S -s /bin/bash bacliup

COPY ./bin/bacliup /fs/usr/local/bin/
COPY ./docker/fs/ /fs/
COPY ./templates/ /fs/etc/bacliup/templates/

RUN mkdir -p /fs/bacliup/.gnupg /fs/etc/bacliup/backups /fs/var/lib/bacliup && \
    chown -R bacliup:bacliup /fs/bacliup /fs/etc/bacliup /fs/var/lib/bacliup && \
    chmod 700 \
      /fs/bacliup \
      /fs/bacliup/.config \
      /fs/bacliup/.config/rclone \
      /fs/bacliup/.gnupg \
      /fs/etc/bacliup \
      /fs/var/lib/bacliup \
    && \
    chmod 600 /fs/bacliup/.config/rclone/rclone.conf

FROM alpine:3.22.1

RUN apk add --no-cache \
      bash \
      busybox-suid \
      curl \
      gettext \
      gnupg \
      jq \
      pv \
      shadow \
      sudo \
    && \
    apk add --no-cache --virtual .build-deps \
      ca-certificates \
      sudo \
      unzip \
    && \
    curl https://rclone.org/install.sh?v=a | sudo bash && \
    apk del .build-deps && \
    addgroup -S bacliup && \
    adduser -D -G bacliup -h /bacliup -S -s /bin/bash bacliup && \
    rm -f /etc/crontabs/root && \
    tar --version && \
    gpg --version && \
    rclone --version

ENV BACLIUP_CRON_SCRIPT="/usr/bin/sudo -u bacliup /usr/local/bin/bacliup" \
    BACLIUP_TEMPLATES_DIR="/etc/bacliup/templates"

WORKDIR /bacliup

COPY --from=builder /fs/ /

RUN chown -R bacliup:bacliup /bacliup /etc/bacliup /var/lib/bacliup

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
