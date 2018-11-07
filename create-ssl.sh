#!/bin/bash

# Usage:
#
# ssl_setup [--self] <name> <csr_config>
#
# This script is used to generate key and CSR for use HTTPS in Nginx.
#
# --self        Generate self-signed certificate in addition to key and CSR.
# name          Output files will be named as <name>.key and <name>.csr.
# csr_config    Path to file that specifies CSR information. See below.
#
# CSR configuration format:
#
# [ req ]
# distinguished_name="req_distinguished_name"
# prompt="no"
#
# [ req_distinguished_name ]
# C="US"
# ST="California"
# L="Albany"
# O="55 Minutes Inc."
# CN="www.55minutes.com"

# if [[ $1 == --self ]]; then
#   shift
# fi

# CREATE SSLCONFIG.txt and v3.ext

SELF_SIGN=1
KEY_NAME=$1
CSR_CONFIG=./sslconfig.txt

#check for v3 file.
#create v3 file with dns entry
#call apache D:\xampp\restart.bat

openssl req -config $CSR_CONFIG -days 365 -new -newkey rsa:2048 -nodes -keyout ${KEY_NAME}.key -out ${KEY_NAME}.csr

echo "Created ${KEY_NAME}.key"
echo "Created ${KEY_NAME}.csr"

if [[ -n $SELF_SIGN ]]; then
  openssl x509 -req  -days 365 -sha256 -in ${KEY_NAME}.csr -signkey ${KEY_NAME}.key -out ${KEY_NAME}.crt -extfile ./v3.ext
  echo "Created ${KEY_NAME}.crt (self-signed)"
fi
echo "------------------------------------------------------------------------------------------------"
echo "Now please enter SSLEngine settings in the vhost config and restart apache/xampp for it to work."