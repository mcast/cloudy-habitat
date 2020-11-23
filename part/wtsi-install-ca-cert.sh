#! /bin/sh

# Based on https://ssg-confluence.internal.sanger.ac.uk/display/OPENSTACK/Adding+the+Sanger+CA+to+an+instance
#          https://gitlab.internal.sanger.ac.uk/CancerIT/CImon/blob/master/cloudinit/bootstrap.txt

set -e
cd "$( dirname "$0" )"

CA_GRL_dir=/usr/share/ca-certificates/sanger.ac.uk
if ! [ -d $CA_GRL_dir ]; then
    openssl x509 -inform der -in ../WTSI-openstack/cacert.crt -out Genome_Research_Ltd_Certificate_Authority-cert.pem
    mkdir $CA_GRL_dir
    mv Genome_Research_Ltd_Certificate_Authority-cert.pem $CA_GRL_dir
    echo "sanger.ac.uk/Genome_Research_Ltd_Certificate_Authority-cert.pem" >> /etc/ca-certificates.conf
    update-ca-certificates -v
fi
