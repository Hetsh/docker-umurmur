#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check access to docker daemon
assert_dependency "docker"
if ! docker version &> /dev/null; then
	echo "Docker daemon is not running or you have unsufficient permissions!"
	exit -1
fi

# Build the image
APP_NAME="umurmur"
IMG_NAME="hetsh/$APP_NAME"
docker build --tag "$IMG_NAME" --tag "$IMG_NAME:$(git describe --tags --abbrev=0)" .

# Start the test
case "${1-}" in
	"--test")
		# Set up temporary directory
		TMP_DIR=$(mktemp -d "/tmp/$APP_NAME-XXXXXXXXXX")
		add_cleanup "rm -rf $TMP_DIR"
		echo "channels = (
	{
		name = \"Test\";
		parent = \"\";
	}
);" > "$TMP_DIR/umurmur.conf"

		# Apply permissions, UID & GID matches process user
		extract_var APP_UID "./Dockerfile" "\K\d+"
		extract_var APP_GID "./Dockerfile" "\K\d+"
		chown -R "$APP_UID":"$APP_GID" "$TMP_DIR"

		# Start the test
		extract_var DATA_DIR "./Dockerfile" "\"\K[^\"]+"
		extract_var CONF_FILE "./Dockerfile" "\"\K[^\"]+"
		docker run \
		--rm \
		--tty \
		--interactive \
		--publish 64738:64738/tcp \
		--publish 64738:64738/udp \
		--mount type=bind,source="$TMP_DIR",target="$DATA_DIR" \
		--mount type=bind,source="$TMP_DIR/umurmur.conf",target="$CONF_FILE" \
		--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
		--name "$APP_NAME" \
		"$IMG_NAME"
	;;
	"--upload")
		if ! tag_exists "$IMG_NAME"; then
			docker push "$IMG_NAME"
		fi
	;;
esac