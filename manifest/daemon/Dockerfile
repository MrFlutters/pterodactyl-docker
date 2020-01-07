ARG ALPINE_VERSION=${ALPINE_VERSION}

FROM node:13.5.0-alpine${ALPINE_VERSION}

LABEL maintainer="MrFlutters"

ARG VERSION

ENV DAEMON_VERSION=${VERSION} \
    UID=500

WORKDIR /srv/daemon

RUN \
 apk --update --no-cache add coreutils curl openssl make gcc g++ python gnupg tar \
 && curl -Lo daemon.tar.gz https://github.com/MrFlutters/pterodactyl-daemon/archive/${DAEMON_VERSION}.tar.gz \
 && tar --strip-components=1 -xzvf daemon.tar.gz \
 && rm -f daemon.tar.gz \
 && npm install --production \
 && addgroup -S -g ${UID} pterodactyl && adduser -S -D -H -G pterodactyl -u ${UID} -s /bin/false pterodactyl \
 && apk del curl make gcc g++ python gnupg \
 && rm -rf /root/.npm /root/.node-gyp /root/.gnupg \
 /var/cache/apk/* /tmp/*

EXPOSE 8080

CMD [ "npm", "start" ]
