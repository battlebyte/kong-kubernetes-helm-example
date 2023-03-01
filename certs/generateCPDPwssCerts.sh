#!/bin/bash

echo "======================================="
echo "========= Create Directories =========="
mkdir -p dp_cert cp_cert ca_cert

echo "======================================="
echo "======== Create CA certificate ========"

openssl genrsa -out ca_cert/ca-cert.key 2048
openssl req -x509 -new -nodes -key ca_cert/ca-cert.key -sha256 -days 1825 -out ca_cert/ca-cert.pem -subj "/C=US/ST=CA/L=SF/O=Kong/OU=CX/CN=konghq.com"

echo "==================================================="
echo "======== Create controle plane certificate ========"

read -p "Please enter your control plane Domaine Name to generate the certificate name [controlplane.kong.lan]: " CPDOMAIN
CPDOMAIN=${CPDOMAIN:-controlplane.kong.lan}
echo $CPDOMAIN

openssl genrsa -out cp_cert/control-plane.key 2048
openssl req -new -key cp_cert/control-plane.key -out cp_cert/control-plane.csr -subj "/C=US/ST=CA/L=SF/O=Kong/OU=CX/CN=konghq.com"

cat > cp_cert/control-plane.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $CPDOMAIN 
EOF

openssl x509 -req -in cp_cert/control-plane.csr -CA ca_cert/ca-cert.pem -CAkey ca_cert/ca-cert.key -CAcreateserial \
-out cp_cert/control-plane.crt -days 825 -sha256 -extfile cp_cert/control-plane.ext 

echo "==================================================="
echo "========== Create data plane certificate =========="

read -p "Please enter your data plane Domaine Name to generate the certificate name [dataplane.kong.lan]: " DPDOMAIN
DPDOMAIN=${DPDOMAIN:-dataplane.kong.lan}
echo $DPDOMAIN

openssl genrsa -out dp_cert/data-plane.key 2048
openssl req -new -key dp_cert/data-plane.key -out dp_cert/data-plane.csr -subj "/C=US/ST=CA/L=SF/O=Kong/OU=CX/CN=konghq.com"

cat > dp_cert/data-plane.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DPDOMAIN
EOF

openssl x509 -req -in dp_cert/data-plane.csr -CA ca_cert/ca-cert.pem -CAkey ca_cert/ca-cert.key -CAcreateserial \
-out dp_cert/data-plane.crt -days 825 -sha256 -extfile dp_cert/data-plane.ext
