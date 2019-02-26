# HAProxy

[![Build Status](https://travis-ci.org/devilbox/docker-haproxy.svg?branch=master)](https://travis-ci.org/devilbox/docker-haproxy)
[![Tag](https://img.shields.io/github/tag/devilbox/docker-haproxy.svg)](https://github.com/devilbox/docker-haproxy/releases)
[![Gitter](https://badges.gitter.im/devilbox/Lobby.svg)](https://gitter.im/devilbox/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Discourse](https://img.shields.io/discourse/https/devilbox.discourse.group/status.svg?colorB=%234CB697)](https://devilbox.discourse.group)
[![](https://images.microbadger.com/badges/version/devilbox/haproxy.svg)](https://microbadger.com/images/devilbox/haproxy "haproxy")
[![](https://images.microbadger.com/badges/image/devilbox/haproxy.svg)](https://microbadger.com/images/devilbox/haproxy "haproxy")
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

This repository provides a customized HAProxy which acts as a SSL-terminating frontend to [Varnish](https://github.com/devilbox/docker-varnish).

| Docker Hub | Upstream Project |
|------------|------------------|
| <a href="https://hub.docker.com/r/devilbox/haproxy"><img height="82px" src="http://dockeri.co/image/devilbox/haproxy" /></a> | <a href="https://github.com/cytopia/devilbox" ><img height="82px" src="https://raw.githubusercontent.com/devilbox/artwork/master/submissions_banner/cytopia/01/png/banner_256_trans.png" /></a> |


## Build

```bash
# Build the Docker image locally
make build

# Rebuild the Docker image locally without cache
make rebuild

# Test the Docker image after building
make test
```


## License

**[MIT License](LICENSE)**

Copyright (c) 2019 [cytopia](https://github.com/cytopia)
