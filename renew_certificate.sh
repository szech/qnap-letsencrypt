#!/bin/bash
set -e
export PATH=/opt/QPython2/bin:$PATH

# VARIABLES, replace these with your own.
DOMAIN="www.example.com"
EMAIL="user@example.com"
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
###########################################
echo DOMAIN = $DOMAIN
echo EMAIL = $EMAIL
echo DIR = $DIR


# do nothing if certificate is valid for more than 30 days (30*24*60*60)
echo "Checking whether to renew certificate on $(date -R)"
[ -s letsencrypt/live/"$DOMAIN"-0001/cert.pem ] && openssl x509 -noout -in letsencrypt/live/"$DOMAIN"-0001/cert.pem -checkend 2592000 && exit


echo "Running letsencrypt, Getting/Renewing certificate..."
letsencrypt certonly --rsa-key-size 4096 --renew-by-default --webroot --webroot-path "/share/Web/" -d $DOMAIN -t --agree-tos --email $EMAIL --config-dir $DIR/letsencrypt 

echo "...Success!"


echo "Stopping stunnel and setting new stunnel certificates..."
/etc/init.d/stunnel.sh stop

echo "live directory = "  letsencrypt/live/"$DOMAIN"-0001
cd letsencrypt/live/"$DOMAIN"-0001
cat privkey.pem cert.pem > /etc/stunnel/stunnel.pem
cp chain.pem /etc/stunnel/uca.pem

echo "Done! Service startup and cleanup will follow now..."
/etc/init.d/stunnel.sh start
/etc/init.d/Qthttpd.sh restart
