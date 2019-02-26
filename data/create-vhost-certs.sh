#!/usr/bin/env bash

set -e
set -u
set -o pipefail

CA_KEY=/ca/devilbox-ca.key
CA_CRT=/ca/devilbox-ca.crt
OUTDIR=/usr/local/etc/haproxy/ssl

VHOST_NAME="${1}"
VHOST_TLD="${2}"
GENERATE_SSL="${3}"

if [ "${GENERATE_SSL}" = "1" ]; then
	_email="admin@${VHOST_NAME}${VHOST_TLD}"
	_domain="${VHOST_NAME}${VHOST_TLD}"
	_domains="*.${VHOST_NAME}${VHOST_TLD}"
	_out_key="/tmp/${VHOST_NAME}${VHOST_TLD}.key"
	_out_csr="/tmp/${VHOST_NAME}${VHOST_TLD}.csr"
	_out_crt="/tmp/${VHOST_NAME}${VHOST_TLD}.crt"
	if ! cert-gen -v -c DE -s Berlin -l Berlin -o Devilbox -u Devilbox -n "${_domain}" -e "${_email}" -a "${_domains}" "${CA_KEY}" "${CA_CRT}" "${_out_key}" "${_out_csr}" "${_out_crt}"; then
		echo "[FAILED] Failed to add SSL certificate for ${VHOST_NAME}${VHOST_TLD}"
		exit 1
	fi
	cat ${_out_crt} ${_out_key} > ${OUTDIR}/${_domain}.pem
fi
