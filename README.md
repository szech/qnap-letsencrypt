# Let's Encrypt on QNAP : Adapted for TS-251 
Inspired by [Yannik's project](https://github.com/Yannik/qnap-letsencrypt) and http://banduccm.blogspot.co.uk/.


## Install Instructions
### NAS Setup
1. Login to your NAS and make sure the following Apps are installed:
      * Git
      * Python 2.7
2. Make sure your NAS is reachable from the public internet under the domain you want to get a certificate for on port 80.
3. Create a folder to store qnap-letsencrypt in under `/share/YOUR_DRIVE/`. Do not create it directly in `/share/`, as it will be lost after a reboot!
4. Download and unzip [QPython2](http://www.positiv-it.fr/QNAP/APP/QPython2_2.7.11.0_x86.qpkg.zip). Install this by going to the App Center in the QNAP web interface, click on the cog icon and then follow the instructions in the popup.


### Setting up a valid ca-bundle and cloning this repo

By default, there is no ca-bundle (bundle of root certificates which we should trust)
installed. Therefore we will have to download one manually.

1. On your local pc with an intact certificate store, run
    ```
    curl -s https://curl.haxx.se/ca/cacert.pem | sha1sum
    ```

2. On your nas, in the directory you want to install qnap-letsencrypt in, run
    ```
    wget --no-check-certificate https://curl.haxx.se/ca/cacert.pem
    sha1sum cacert.pem
    ```

3. Compare the hashes obtained in step 1 and 2, they must match.

4. On your nas, in the directory you were in before
    ```
    git config --system http.sslVerify true
    git config --system http.sslCAinfo cacert.pem
    git clone https://github.com/szech/qnap-letsencrypt.git
    mv cacert.pem qnap-letsencrypt
    cd qnap-letsencrypt
    git config --system http.sslCAinfo cacert.pem
    ```

### Setting up qnap-letsencrypt
1. Edit `renew_certificate` and put your own values in the `VARIABLES` section   

2. `mv /etc/stunnel/stunnel.pem /etc/stunnel/stunnel.pem.orig` (backup, though we can always recover through the web gui)

3. Run `renew_certificate.sh`

4. Create a cronjob to run `renew_certificate.sh` every night, which will renew your certificate if it has less than 30 days left

    Add this to `/etc/config/crontab`:
    ```
    30 3 * * * cd /share/YOUR_INSTALL_LOCATION/qnap-letsencrypt/ && ./renew_certificate.sh >> ./renew_certificate.log 2>&1
    ```

    Then run:
    ```
    crontab /etc/config/crontab
    /etc/init.d/crond.sh restart
    ```

### FAQ

#### Why did you create this fork?
I am just running the default Qnap web server on a custom domain. I had some problems getting the python web server working in Yannik's project, so i decided to fork and pursue a different approach.

#### What's different to Yannik's original script?
- we install custom package QPython2 so we can run the letsencrypt client natively. This means we don't run the Python web server, or the acme-tiny client. QPython2 is a 1GB monster that has a lot more than what we need, but i did not find any other convenient source for the letsencrypt client which does not run natively on qnap OS. QPython is sourced from [here](http://forum.qnap.com/viewtopic.php?f=217&t=109899).
- only support for one domain; you are welcome to fork and figure out your own approach ;-)
 
#### There is a newer version of QPython2, why aren't you using that?
letsencrypt seems to have some broken dependencies in 2_2.7.11.0.1 and isn't working. 

#### I disagree with your terrible code!
I'm no expert, please respond if you have some feedback for me.

#### How can I contribute anything to this project?
Please open a pull request!

#### What license is this code licensed under?
GPLv2
