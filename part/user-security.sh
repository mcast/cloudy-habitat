#! /bin/bash
# Bash for pipefail

# Disconnect this instance from the OS image default user.  Run as root or a sudo-able user.
# Destroys the current user - requires flag to acknowledge that!
#
# Based on (internal) https://confluence.sanger.ac.uk/display/IT/OpenStack+-+development+host+quickstart

set -e
set -o pipefail

if [ "$1" = '--destroy-luser-and-homedir' ]; then
    luser=$2
else
    echo Safety catch was not disengaged >&2
    exit 1
fi

AUTHK=/home/$luser/.ssh/authorized_keys
NEWUSER=$( perl -ne '
 next if /^\s*(#|$)/;
 next if / Generated-by-Nova\b/;
 s{^(.+?\s+)?ssh-\w+\s+\S{64,}\s+}{};
 s{(@|\s+).*}{};
 print;
' $AUTHK | head -n1 )
echo Create non-default user $NEWUSER based on $AUTHK

if [ "$NEWUSER" = "$luser" ]; then
    echo Task $0 done already
    exit 0
fi

_in_etc_passwd() {
    grep -qE ^$1: /etc/passwd
}

_user_homedir() {
    perl -e 'my $u=shift(); my @u=getpwnam($u) or die "user $u not found\n"; print $u[7]' $1
}

if NEWUSER_ldap_home=$( _user_homedir $NEWUSER ) && ! [ -d $NEWUSER_ldap_home ]; then
    echo "Homedir $NEWUSER_ldap_home does not, but $NEWUSER does exist (LDAP?)"
    sudo mkdir -p $NEWUSER_ldap_home
    sudo rmdir    $NEWUSER_ldap_home
    sudo cp -a /etc/skel $NEWUSER_ldap_home
    sudo ln -s $NEWUSER_ldap_home /home/$NEWUSER
    sudo chown -R $NEWUSER:$( id -n -g $luser ) $NEWUSER_ldap_home
elif ! _in_etc_passwd $NEWUSER; then
    echo Set up new local user $NEWUSER
    sudo adduser --ingroup $( id -n -g $luser ) --disabled-password --gecos '' $NEWUSER
fi

for gid in $( id -n -G $luser ); do
    sudo adduser $NEWUSER $gid
done

# paste existing pubkey
sudo -u $NEWUSER -H bash -c 'cd; mkdir .ssh; cat > .ssh/authorized_keys; chmod -R go-rwx .ssh' < $AUTHK


echo "$NEWUSER ALL=(ALL) NOPASSWD:ALL" | sudo dd of=/etc/sudoers.d/90-cloud-init-users
# replace existing file made by openstack --> original user ubuntu has no password, can no longer sudo!

### block attachement of new Key Pairs through the Horizon interface
deluser --remove-home ubuntu

# continues in cloud-init.sh with another fetch_proj
