# HAProxy

[![Build Status](https://travis-ci.org/devilbox/docker-haproxy.svg?branch=master)](https://travis-ci.org/devilbox/docker-haproxy)
[![Tag](https://img.shields.io/github/tag/devilbox/docker-haproxy.svg)](https://github.com/devilbox/docker-haproxy/releases)
[![Gitter](https://badges.gitter.im/devilbox/Lobby.svg)](https://gitter.im/devilbox/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Discourse](https://img.shields.io/discourse/https/devilbox.discourse.group/status.svg?colorB=%234CB697)](https://devilbox.discourse.group)
[![](https://images.microbadger.com/badges/version/devilbox/haproxy.svg)](https://microbadger.com/images/devilbox/haproxy "haproxy")
[![](https://images.microbadger.com/badges/image/devilbox/haproxy.svg)](https://microbadger.com/images/devilbox/haproxy "haproxy")
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

This repository provides a customized HAProxy which acts as a SSL-terminating frontend to [Varnish](https://github.com/devilbox/docker-varnish).
HAProxy will generate SSL certificates based on Devilbox CA to ensure you have valid HTTPS for local development.

This Docker image is very customized to fit the Devilbox and will probably not work without it.

| Docker Hub | Upstream Project |
|------------|------------------|
| <a href="https://hub.docker.com/r/devilbox/haproxy"><img height="82px" src="http://dockeri.co/image/devilbox/haproxy" /></a> | <a href="https://github.com/cytopia/devilbox" ><img height="82px" src="https://raw.githubusercontent.com/devilbox/artwork/master/submissions_banner/cytopia/01/png/banner_256_trans.png" /></a> |

#### Documentation

In case you seek help, go and visit the community pages.

<table width="100%" style="width:100%; display:table;">
 <thead>
  <tr>
   <th width="33%" style="width:33%;"><h3><a target="_blank" href="https://devilbox.readthedocs.io">Documentation</a></h3></th>
   <th width="33%" style="width:33%;"><h3><a target="_blank" href="https://gitter.im/devilbox/Lobby">Chat</a></h3></th>
   <th width="33%" style="width:33%;"><h3><a target="_blank" href="https://devilbox.discourse.group">Forum</a></h3></th>
  </tr>
 </thead>
 <tbody style="vertical-align: middle; text-align: center;">
  <tr>
   <td>
    <a target="_blank" href="https://devilbox.readthedocs.io">
     <img title="Documentation" name="Documentation" src="https://raw.githubusercontent.com/cytopia/icons/master/400x400/readthedocs.png" />
    </a>
   </td>
   <td>
    <a target="_blank" href="https://gitter.im/devilbox/Lobby">
     <img title="Chat on Gitter" name="Chat on Gitter" src="https://raw.githubusercontent.com/cytopia/icons/master/400x400/gitter.png" />
    </a>
   </td>
   <td>
    <a target="_blank" href="https://devilbox.discourse.group">
     <img title="Devilbox Forums" name="Forum" src="https://raw.githubusercontent.com/cytopia/icons/master/400x400/discourse.png" />
    </a>
   </td>
  </tr>
  <tr>
  <td><a target="_blank" href="https://devilbox.readthedocs.io">devilbox.readthedocs.io</a></td>
  <td><a target="_blank" href="https://gitter.im/devilbox/Lobby">gitter.im/devilbox</a></td>
  <td><a target="_blank" href="https://devilbox.discourse.group">devilbox.discourse.group</a></td>
  </tr>
 </tbody>
</table>


## Build

```bash
# Build the Docker image locally
make build

# Rebuild the Docker image locally without cache
make rebuild

# Test the Docker image after building
make test
```

## Environment variables

**Note:** All variables are required for HAProxy to startup.

| Variable           | Default value   | Description |
|--------------------|-----------------|-------------|
| BACKEND_ADDR       | ``              | Hostname or IP of backend service to connect to over HTTP. |
| BACKEND_PORT       | ``              | HTTP port of backend service to connectto over HTTP. |
| DEVILBOX_UI_SSL_CN | ``              | Comma separated list of domain names and/or wildcards for which to generate SSL certificates by default |
| TLD_SUFFIX         | ``              | Devilbox TLD_SUFFIX (e.g.: `loc`) to append to all domains, which is required for SSL certificate generation |


## Mount points

**Note:** All mountpoints are required for HAProxy to startup.

| Container path  | Description |
|-----------------|-------------|
| /ca/            | Expects Devilbox CA files to be mounted there. Two files must be present: `devilbox-ca.key` and `devilbox-ca.crt` |
| /shared/httpd   | Expects Devilbox project directories to be present for SSL certificate generation via [watcherd](https://github.com/devilbox/watcherd) |

## Ports

By default HAProxy will be available via `80` (for HTTP) and via `443` (for HTTPS offloading).


## Examples

The following shows a Docker Compose example to use Varnish and HAProxy as an SSL offloading proxy
in front of it.

```yml
version: '2.1'

services:

  varnish:
    image: devilbox/varnish:${VARNISH_SERVER:-6}-0.3
    hostname: varnish
    ports:
      - "${LOCAL_LISTEN_ADDR}${HOST_PORT_VARNISH:-6081}:6081"
    networks:
      app_net:
        ipv4_address: 172.16.238.230
    environment:
      - VARNISH_CONFIG=/etc/varnish/default.vcl
      - CACHE_SIZE=${VARNISH_CACHE_SIZE:-128m}
      - VARNISHD_PARAMS=${VARNISH_PARAMS:--p default_ttl=3600 -p default_grace=3600}
      - BACKEND_HOST=httpd
      - BACKEND_PORT=80
    volumes:
      - ${DEVILBOX_PATH}/cfg/varnish-${VARNISH_SERVER:-6}:/etc/varnish.d
    depends_on:
      - bind
      - php
      - httpd

  haproxy:
    image: devilbox/haproxy:0.1
    hostname: haproxy
    ports:
      - "${LOCAL_LISTEN_ADDR}${HOST_PORT_HAPROXY:-8080}:80"
      - "${LOCAL_LISTEN_ADDR}${HOST_PORT_HAPROXY_SSL:-8443}:443"
    networks:
      app_net:
        ipv4_address: 172.16.238.231
    environment:
      - BACKEND_ADDR=varnish
      - BACKEND_PORT=6081
      - DEVILBOX_UI_SSL_CN
      - TLD_SUFFIX
    volumes:
      # Certificate Authority public key
      - ${DEVILBOX_PATH}/ca:/ca:rw${MOUNT_OPTIONS}
      # Mount custom mass virtual hosting
      - ${HOST_PATH_HTTPD_DATADIR}:/shared/httpd:rw${MOUNT_OPTIONS}
    depends_on:
      - bind
      - php
      - httpd
      - varnish
```


## License

**[MIT License](LICENSE)**

Copyright (c) 2019 [cytopia](https://github.com/cytopia)
