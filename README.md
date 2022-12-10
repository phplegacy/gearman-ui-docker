# Gearman UI Docker image

<p align="center"><a href="https://github.com/phplegacy/gearman-ui-docker"><img src="https://github.com/phplegacy/gearman-ui-docker/raw/master/docs/gearman-ui.png"></a></p>


Docker image for [Gearman UI](https://github.com/phplegacy/gearman-ui), a small PHP application providing a minimal monitoring dashboard for a cluster of Gearman Job Servers.

## Docker repository
[Docker Hub](https://hub.docker.com/r/legacyphp/gearman-ui)  
`docker pull legacyphp/gearman-ui:latest`

[GitHub Packages](https://github.com/phplegacy/gearman-ui-docker/pkgs/container/gearman-ui-docker)  
`docker pull ghcr.io/phplegacy/gearman-ui-docker:latest`

## Usage

Use provided [`docker-compose.yml`](https://github.com/phplegacy/gearman-ui-docker/blob/master/docker-compose.yml) as an example.

## Configuration

Use environment variables to define gearman server name, address and port:  
```sh
GEARMAN_SERVERS = 'Gearman#1:gearman:4730';
```

Separate configuration with comma in order to connect to multiple gearman servers:
```sh
GEARMAN_SERVERS = 'Gearman#1:gearman:4730,Gearman#2:gearman2:4730';
```

## License

The MIT License (MIT). Please see [License File](https://github.com/phplegacy/gearman-ui-docker/blob/master/LICENSE) for more information.

---
If you like this project, please consider giving me a ⭐
