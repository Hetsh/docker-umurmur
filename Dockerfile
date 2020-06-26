FROM library/alpine:20200626
RUN apk add --no-cache \
    umurmur=0.2.17-r4

# App user
ARG APP_USER="umurmur"
ARG	OLD_UID=100
ARG	APP_UID=1364
ARG APP_GROUP="umurmur"
ARG	OLD_GID=101
ARG	APP_GID=1364
RUN sed -i "/:$APP_UID/d" /etc/passwd && \
    sed -i "s|$APP_USER:x:$OLD_UID:$OLD_GID|$APP_USER:x:$APP_UID:$APP_GID|" /etc/passwd && \
    sed -i "/:$APP_GID/d" /etc/group && \
    sed -i "s|$APP_GROUP:x:$OLD_GID:$OLD_USER|$APP_GROUP:x:$APP_GID:|" /etc/group

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
