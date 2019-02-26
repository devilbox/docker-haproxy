#!/usr/bin/env bash

set -e
set -u
set -o pipefail


# -------------------------------------------------------------------------------------------------
# Check required env variables
# -------------------------------------------------------------------------------------------------

if ! env | grep -q '^DEVILBOX_UI_SSL_CN='; then
	>&2 echo "[ERROR] Required env variable not set: DEVILBOX_UI_SSL_CN"
	exit 1
fi

if ! env | grep -q '^TLD_SUFFIX='; then
	>&2 echo "[ERROR] Required env variable not set: TLD_SUFFIX"
	exit 1
fi


# -------------------------------------------------------------------------------------------------
# Check required mounts
# -------------------------------------------------------------------------------------------------

# The CA files are initially generated by the Devilbox webserver (Apache or Nginx).
# To prevent the race condition from starting HAProxy earlier than the webserver and not
# having the certificate available yet, we will wait here and probe if the file exists
MAX=60

CNT=0
printf "Probing for /ca/devilbox-ca.key "
while [ ! -f /ca/devilbox-ca.key ]; do
	sleep 1
	CNT=$((CNT+1))
	printf "."
	if [ "${CNT}" -ge "${MAX}" ]; then
		printf "\n"
		>&2 echo "[ERROR] Coult not find /ca/devilbox-ca.key after ${MAX} seconds"
		exit 1
	fi
done
printf "\n"

CNT=0
printf "Probing for /ca/devilbox-ca.crt "
while [ ! -f /ca/devilbox-ca.crt ]; do
	sleep 1
	CNT=$((CNT+1))
	printf "."
	if [ "${CNT}" -ge "${MAX}" ]; then
		printf "\n"
		>&2 echo "[ERROR] Coult not find /ca/devilbox-ca.crt after ${MAX} seconds"
		exit 1
	fi
done
printf "\n"


# -------------------------------------------------------------------------------------------------
# Replace placeholder if /usr/local/etc/haproxy/haproxy.cfg exists
# -------------------------------------------------------------------------------------------------

if [ -f /usr/local/etc/haproxy/haproxy.cfg ]; then
	HA_VERSION="$( haproxy -v | grep -Eo 'HA(-)?Proxy(\sversion)?\s+[.0-9]+' | grep -Eo '[.0-9]+' )"
	sed -i'' "s/__VERSION__/${HA_VERSION}/g" /usr/local/etc/haproxy/haproxy.cfg

	if env | grep -q '^BACKEND_ADDR='; then
		BACKEND_ADDR="$( env | grep '^BACKEND_ADDR=' | sed 's/^BACKEND_ADDR=//g' )"
		sed -i'' "s/__BACKEND_ADDR__/${BACKEND_ADDR}/g" /usr/local/etc/haproxy/haproxy.cfg
	fi
	if env | grep -q '^BACKEND_PORT='; then
		BACKEND_PORT="$( env | grep '^BACKEND_PORT=' | sed 's/^BACKEND_PORT=//g' )"
		sed -i'' "s/__BACKEND_PORT__/${BACKEND_PORT}/g" /usr/local/etc/haproxy/haproxy.cfg
	fi
fi


# -------------------------------------------------------------------------------------------------
# Replace TLD_SUFFIX in supervisord.conf
# -------------------------------------------------------------------------------------------------

sed -i'' "s/__TLD_SUFFIX__/${TLD_SUFFIX}/g" /etc/supervisord.conf


# -------------------------------------------------------------------------------------------------
# Ensure SSL certificates exist for UI
# -------------------------------------------------------------------------------------------------

for dom in for i in ${DEVILBOX_UI_SSL_CN//,/ }; do
	cert-gen -v -c DE -s Berlin -l Berlin -o Devilbox -u Devilbox \
		-n "${dom}" -e "admin@${dom}" \
		-a "*.${dom}" \
		/ca/devilbox-ca.key \
		/ca/devilbox-ca.crt \
		/tmp/${dom}.key \
		/tmp/${dom}.csr \
		/tmp/${dom}.crt
	cat /tmp/${dom}.crt /tmp/${dom}.key > /usr/local/etc/haproxy/ssl/${dom}.pem
done


# -------------------------------------------------------------------------------------------------
# Parse startup options to HAProxy
# -------------------------------------------------------------------------------------------------

exec /usr/bin/supervisord -c /etc/supervisord.conf
