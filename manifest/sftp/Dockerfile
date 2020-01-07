ARG ALPINE_VERSION=${ALPINE_VERSION}

# Build sftp-server artifact
FROM golang:alpine${ALPINE_VERSION} as BUILDER
RUN apk add git
ARG VERSION
ENV SFTP_VERSION=${VERSION}
RUN git clone -b release/${SFTP_VERSION} https://github.com/MrFlutters/pterodactyl-sftp-server.git /app
WORKDIR /app 
RUN GOOS=linux go build -o /app/build/sftp-server .

# Build runtime Image

FROM alpine:${ALPINE_VERSION}

LABEL maintainer="MrFlutters"

ENV UID=500
RUN mkdir -p /srv/sftp
COPY --from=BUILDER /app/build/sftp-server /srv/sftp/sftp-server

RUN chmod +x /srv/sftp/sftp-server \
    && addgroup -S -g ${UID} pterodactyl \
    && adduser -S -D -H -G pterodactyl -u ${UID} -s /bin/false pterodactyl

WORKDIR /srv/sftp
ENTRYPOINT [ "./sftp-server" ]