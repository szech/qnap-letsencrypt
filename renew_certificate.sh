#!/bin/bash
set -e
export PATH=/opt/QPython2/bin:$PATH

# VARIABLES, replace these with your own.
DOMAIN="www.example.com"
EMAIL="user@example.com"
###########################################
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# do nothing if certificate is valid for more than 30 days (30*24*60*60)
echo "Checking whether to renew certificate on $(date -R)"
[ -s letsencrypt/signed.crt ] && openssl x509 -noout -in letsencrypt/signed.crt -checkend 2592000 && exit

echo "Running letsencrypt, Getting/Renewing certificate..."
letsencrypt certonly --rsa-key-size 4096 --renew-by-default --webroot --webroot-path "/share/Web/" -d $DOMAIN -t --agree-tos --email $EMAIL --config-dir $DIR/letsencrypt 

echo "...Success!"

echo "Stopping stunnel and setting new stunnel certificates..."
/etc/init.d/stunnel.sh stop

cd letsencrypt/live/$DOMAIN
cat privkey.pem cert.pem chain.pem > /etc/stunnel/stunnel.pem
cp fullchain.pem /etc/stunnel/uca.pem

echo "Done! Service startup and cleanup will follow now..."
/etc/init.d/stunnel.sh start


