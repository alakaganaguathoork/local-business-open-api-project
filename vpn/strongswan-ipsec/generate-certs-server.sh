#!/bin/bash

set -e


CERTS_DIR="generated-certs"
DISTINGUISHED_NAME="C=UA, O=HomeLab, CN=VPN Root CA"

if [[ ! -d "$CERTS_DIR" ]]; then
    printf "no directory %s \n" "$CERTS_DIR"
    mkdir -p $CERTS_DIR/{certs,cacerts,private}
fi

cd generated-certs/


generate_ca_cert() {
    # CA private key
    pki --gen --type rsa --size 4096 \
        --outform pem > private/ca.key.pem

    # CA certificate
    pki --self --ca --lifetime 3650 \
        --digest sha256 \
        --in private/ca.key.pem \
        --dn "$DISTINGUISHED_NAME" \
        --ca \
        --outform pem > cacerts/ca.cert.pem
}

generate_server_cert() {
    # Server key
    pki --gen --type rsa --size 4096 \
        --outform pem > private/server.key.pem

    # Server cert
    pki --pub --in private/server.key.pem | \
    pki --issue --lifetime 3650 \
        --digest sha256 \
        --cacert cacerts/ca.cert.pem \
        --cakey private/ca.key.pem \
        --dn "$DISTINGUISHED_NAME" \
        --san "mishap" --san "192.168.50.212" \
        --flag serverAuth \
        --flag ikeItermediate \
        --ca \
        --outform pem > certs/server.cert.pem
}

generate_ca_cert
generate_server_cert