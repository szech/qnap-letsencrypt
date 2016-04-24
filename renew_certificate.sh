#!/bin/bash
set -e
export PATH=/opt/QPython2/bin:$PATH

# VARIABLES, replace these with your own.
DOMAIN="szech.ikolantaksit.fi"
EMAIL="adrian.jh.chu@gmail.com"
WORKING_DIR="/share/homes/admin/qnap-letsencrypt"


# do nothing if certificate is valid for more than 30 days (30*24*60*60)
echo "Checking whether to renew certificate on $(date -R)"
[ -s letsencrypt/signed.crt ] && openssl x509 -noout -in letsencrypt/signed.crt -checkend 2592000 && exit

echo "Renewing certificate..."
# echo "Stopping Qthttpd hogging port 80.."

# /etc/init.d/Qthttpd.sh stop



DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# mkdir -p /share/Web/.well-known/acme-challenge
# cd /share/Web/.well-known/acme-challenge
# python -m SimpleHTTPServer 80 &
# pid=$!
# echo "Started python SimpleHTTPServer with pid $pid"

letsencrypt certonly --rsa-key-size 4096 --renew-by-default --webroot --webroot-path "/share/Web/" -d 
$DOMAIN -t --agree-tos --email $EMAIL --config-dir $WORKING_DIR 


#cd $DIR
# export SSL_CERT_FILE=cacert.pem
# python acme-tiny/acme_tiny.py --account-key letsencrypt/account.key --csr letsencrypt/domain.csr 
# --acme-dir /share/Web/.well-known/acme-challenge > letsencrypt/signed.crt
# echo "Downloading intermediate certificate..."
# wget --no-verbose -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > 
# letsencrypt/intermediate.pem
# cat letsencrypt/signed.crt letsencrypt/intermediate.pem > letsencrypt/chained.pem

echo "Stopping stunnel and setting new stunnel certificates..."
/etc/init.d/stunnel.sh stop
cd letsencrypt/live/$DOMAIN
cat privkey.pem cert.pem chain.pem > /etc/stunnel/stunnel.pem
cp fullchain.pem /etc/stunnel/uca.pem

echo "Done! Service startup and cleanup will follow now..."
/etc/init.d/stunnel.sh start

# kill -9 $pid || true
# rm -rf tmp-webroot

# /etc/init.d/Qthttpd.sh start
