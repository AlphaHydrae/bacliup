FROM alpine:3.16.1

RUN apk add --no-cache gnupg && \
    apk add --no-cache --virtual .build-deps bash ca-certificates curl sudo unzip && \
    curl https://rclone.org/install.sh | sudo bash && \
    apk del .build-deps && \
    gpg --version && \
    rclone --version

CMD [ "crond", "-f" ]
