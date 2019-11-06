#! /bin/sh

cd "$( dirname "$0" )"
wget -O cacert.crt 'https://ca.sanger.ac.uk/cgi-bin/catool?action=DownloadCACert'
