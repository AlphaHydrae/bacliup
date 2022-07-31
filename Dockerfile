FROM alpine:3.16.1 as builder

COPY --chown=bacliup:bacliup ./bin/bacliup /fs/usr/local/bin/
COPY --chown=bacliup:bacliup ./docker/ /fs/
RUN chmod 700 /fs/bacliup /fs/bacliup/.config /fs/bacliup/.config/rclone && \
    chmod 600 /fs/bacliup/.config/rclone/rclone.conf

FROM alpine:3.16.1

RUN apk add --no-cache bash curl gnupg && \
    apk add --no-cache --virtual .build-deps \
      ca-certificates \
      sudo \
      unzip \
    && \
    curl https://rclone.org/install.sh | sudo bash && \
    apk del .build-deps && \
    addgroup -S bacliup && \
    adduser -D -G bacliup -h /bacliup -S -s /bin/bash bacliup && \
    gpg --version && \
    rclone --version

USER bacliup
WORKDIR /bacliup

COPY --chown=bacliup:bacliup --from=builder /fs/ /

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
