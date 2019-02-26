# vim: set ft=dockerfile:
FROM haproxy:1

ARG CERTGEN=0.3
ARG WATCHERD=master

RUN set -x \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
		psmisc \
		supervisor \
	&& curl -sS -L -o /usr/local/bin/cert-gen https://raw.githubusercontent.com/devilbox/cert-gen/${CERTGEN}/bin/cert-gen \
	&& curl -sS -L -o /usr/local/bin/watcherd https://raw.githubusercontent.com/devilbox/watcherd/${WATCHERD}/watcherd \
	&& chmod +x /usr/local/bin/cert-gen \
	&& chmod +x /usr/local/bin/watcherd \
	&& DEBIAN_FRONTEND=noninteractive apt-get purge -qq -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
		curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /etc/supervisor* \
	&& mkdir -p /usr/local/etc/haproxy/ssl

COPY data/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY data/supervisord.conf /etc/supervisord.conf
COPY data/create-vhost-certs.sh /usr/local/bin/create-vhost-certs.sh
COPY data/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
