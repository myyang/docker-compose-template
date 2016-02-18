#!/bin/bash

HOST=localhost
HOST_IP=127.0.0.1

# generate ca
openssl genrsa -aes256 -out ca-key.pem 4096
openssl req -new -x509 -days 365 -subj "/C=TW/ST=Taipei/L=Taipei/O=Self/CN=$HOST" -key ca-key.pem -sha256 -out ca.pem

# remote docker daemon
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr
echo subjectAltName = IP:$HOST_IP,IP:127.0.0.1 > extfile.cnf
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf


# local client key pair
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo extendedKeyUsage = clientAuth > extfile.cnf
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf

# secure
chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem

mkdir certs && cp ca.pem cert.pem key.pem certs/
mkdir scerts && cp ca.pem server-cert.pem server-key.pem scerts/

# clean
rm client.csr server.csr extfile.cnf *.pem

echo -e "\n

1. Secure remote:
Copy 'scerts' to remote docker daemon, and restart with opts:\n
-H tcp://0.0.0.0:2376 --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem\n

2. Local key:
Here are alternatie approach:\n
  * Put 'certs/*.pem' under ~/.docker/
  * Run with opts
  * Use env param DOCKER_CERT_PATH, DOCKER_HOST, DOCKER_TLS_VERIFY

"


