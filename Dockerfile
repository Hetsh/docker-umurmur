FROM library/alpine:20200428
RUN apk add --no-cache \
    murmur=1.3.0-r6

# App user
ARG APP_USER="murmur"
ARG	OLD_UID=100
ARG	APP_UID=1363
ARG APP_GROUP="murmur"
ARG	OLD_GID=101
ARG	APP_GID=1363
RUN sed -i "/:$APP_UID/d" /etc/passwd && \
    sed -i "s|$APP_USER:x:$OLD_UID:$OLD_GID:Mumble daemon|$APP_USER:x:$APP_UID:$APP_GID:mumble server daemon|" /etc/passwd && \
    sed -i "/:$APP_GID/d" /etc/group && \
    sed -i "s|$APP_GROUP:x:$OLD_GID:$OLD_USER|$APP_GROUP:x:$APP_GID:|" /etc/group

# Volumes
ARG CONF_DIR="/var/lib/murmur"
RUN mv /etc/murmur.ini "$CONF_DIR" && \
    chown -R "$APP_USER":"$APP_GROUP" "$CONF_DIR"
VOLUME ["$CONF_DIR"]

#      CONTROL     VOICE
EXPOSE 64738/tcp   64738/udp

USER "$APP_USER"
WORKDIR "$CONF_DIR"
ENTRYPOINT ["murmurd", "-fg", "-ini", "murmur.ini"]
