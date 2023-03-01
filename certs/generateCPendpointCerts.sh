#!/bin/bash

mkdir -p ssl-certs

read -p "Please enter a domain name to use for manager, adminapi, portal, portalapi and api [kong.lan]: " DOMAIN
DOMAIN=${DOMAIN:-kong.lan}
echo $DOMAIN

openssl genrsa -out ssl-certs/control-plane-components.key 2048
openssl req -new -key ssl-certs/control-plane-components.key -out ssl-certs/control-plane-components.csr -subj "/C=US/ST=CA/L=SF/O=Kong/OU=CX/CN=konghq.com"

cat > ssl-certs/control-plane-components.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = manager.$DOMAIN
DNS.2 = adminapi.$DOMAIN
DNS.3 = portal.$DOMAIN
DNS.4 = portalapi.$DOMAIN
DNS.5 = api.$DOMAIN
EOF

openssl x509 -req -in ssl-certs/control-plane-components.csr -CA ca_cert/ca-cert.pem -CAkey ca_cert/ca-cert.key -CAcreateserial -out ssl-certs/control-plane-components.crt -days 825 -sha256 -extfile ssl-certs/control-plane-components.ext
