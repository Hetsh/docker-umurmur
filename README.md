# umurmur
Super small and easy to setup micro mumble server.

## Running the server
```bash
docker run --detach --name umurmur --publish 64738:64738/tcp --publish 64738:64738/udp hetsh/umurmur
```

## Stopping the container
```bash
docker stop umurmur
```

## Configuration
umurmur can be configured with a configuration file `/etc/umurmur.conf`.
A minimum config file must contain a root channel:
```
channels = (
	{
		name = "Root";
		parent = "";
	}
);
```
A custom configuration can be added as read-only:
```bash
docker run --mount type=bind,source=/path/to/umurmur.conf,target=/etc/umurmur.conf,readonly ...
```

## Creating persistent storage
```bash
DATA="/path/to/data"
mkdir -p "$DATA"
chown -R 1634:1634 "$DATA"
```
`1634` is the numerical id of the user running the server (see Dockerfile).
The user must have RW access to the data directory.
Start the server with the additional mount flags:
```bash
docker run --mount type=bind,source=/path/to/data,target=/etc/umurmur ...
```

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-umurmur).
```bash
systemctl enable umurmur --now
```
By default, the systemd service assumes `/apps/umurmur/data` for data and `/apps/umurmur/umurmur.conf` for config and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-umurmur)).
Please feel free to ask questions, file an issue or contribute to it.