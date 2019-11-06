#! /bin/sh

# Based on https://ssg-confluence.internal.sanger.ac.uk/display/OPENSTACK/Adding+the+Sanger+CA+to+an+instance
#          https://gitlab.internal.sanger.ac.uk/CancerIT/CImon/blob/master/cloudinit/bootstrap.txt

set -e
cd "$( dirname "$0" )"

openssl x509 -inform der -in ../WTSI-openstack/cacert.crt -out Genome_Research_Ltd_Certificate_Authority-cert.pem
mkdir /usr/share/ca-certificates/sanger.ac.uk
mv Genome_Research_Ltd_Certificate_Authority-cert.pem /usr/share/ca-certificates/sanger.ac.uk
echo "sanger.ac.uk/Genome_Research_Ltd_Certificate_Authority-cert.pem" >> /etc/ca-certificates.conf
update-ca-certificates -v
