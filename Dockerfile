FROM alpine:3.16.1 as builder

COPY ./bin/bacliup /fs/usr/local/bin/
COPY ./docker/ /fs/

RUN chmod 700 /fs/bacliup /fs/bacliup/.config /fs/bacliup/.config/rclone && \
    chmod 600 /fs/bacliup/.config/rclone/rclone.conf

FROM alpine:3.16.1

ENV BACLIUP_CRON_SCRIPT="/usr/local/bin/with-env /usr/local/bin/bacliup"

RUN mkdir -p /var/run/bacliup/environment && \
    apk add --no-cache bash busybox-suid curl gettext gnupg jq postgresql-client pv && \
    apk add --no-cache --virtual .build-deps \
      ca-certificates \
      sudo \
      unzip \
    && \
    curl https://rclone.org/install.sh | sudo bash && \
    apk del .build-deps && \
    addgroup -g 4200 -S bacliup && \
    adduser -D -G bacliup -h /bacliup -S -s /bin/bash -u 4200 bacliup && \
    chown -R bacliup:bacliup /var/run/bacliup && \
    chmod -R 700 /var/run/bacliup && \
    rm -f /etc/crontabs/root && \
    gpg --version && \
    rclone --version

USER bacliup
WORKDIR /bacliup

COPY --chown=bacliup:bacliup --from=builder /fs/ /

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
