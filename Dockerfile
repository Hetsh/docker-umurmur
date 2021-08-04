FROM amd64/alpine:20210804
RUN apk add --no-cache \
        umurmur=0.2.20-r0

# App user
ARG APP_USER="umurmur"
ARG APP_UID=1364
ARG APP_GROUP="umurmur"
ARG APP_GID=1364
RUN sed -i "/:$APP_UID/d" /etc/passwd && \
    sed -i "s|$APP_USER:x:[0-9]\+:[0-9]\+|$APP_USER:x:$APP_UID:$APP_GID|" /etc/passwd && \
    sed -i "/:$APP_GID/d" /etc/group && \
    sed -i "s|$APP_GROUP:x:[0-9]\+:$APP_USER|$APP_GROUP:x:$APP_GID:|" /etc/group

# Volumes
ARG DATA_DIR="/etc/umurmur"
ARG CONF_FILE="/etc/umurmur.conf"
RUN chown -R "$APP_USER":"$APP_GROUP" "$DATA_DIR" && \
    mv "$DATA_DIR/umurmurd.conf" "$CONF_FILE"
VOLUME ["$DATA_DIR"]

#      CONTROL     VOICE
EXPOSE 64738/tcp   64738/udp

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT ["umurmurd", "-d"]
