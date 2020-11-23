#! /bin/sh

vmname=mca-irods-nonci

key_name=mca-eta

openrc=$HOME/openrc/theta-casm-general-openrc.sh
network=cloudforms_network
image=bionic-WTSI-docker_49930_38ab07e9
image=bionic-WTSI-irodsclient_55347_08487c1f

OS_NOISY=1

set -e

script_dir="$( dirname "$0" )"

# how mca sets up his openstack command
unset http_proxy
unset https_proxy
unset no_proxy
unset PYTHONPATH
. $HOME/_py.sw374/bin/activate
. "$openrc"

_kvp() {
    key=$1
    shift
    for val in "$@"; do
	echo $key $val
    done
}

_do() {
    (
	set -x
	"$@"
    )
}

if ! [ -f ~/".ssh/keypairs/$key_name" ]; then
    echo ~/".ssh/keypairs/$key_name: private key not where I expected" >&2
    exit 2
fi

if vm_create="$(

_do openstack server create \
	  --image $image --flavor o2.medium --key-name $key_name \
	  $( _kvp --security-group cloudforms_local_in cloudforms_web_in default cloudforms_ext_in cloudforms_ssh_in ) \
	  --network $network \
	  --format json \
	  --user-data "$script_dir/cloud-init.sh" \
	  --wait $vmname
)"; then
#    echo "$vm_create" > tmp.json # ugly. this json comes back sometimes with literal \n inside strings, which jq rejects
    vm_id=$( echo "$vm_create" | ./$script_dir/../json-cleanup | jq --raw-output .id )
    printf "\nCreated $vm_id ok\n\n%s\n" "$vm_create"
fi

if [ -n "$vm_id" ]; then
    echo Have host id=$vm_id
    float_info="$( _do openstack floating ip list -f json )"
    floatip=$( echo "$float_info" | jq --raw-output 'map(select(.Port | not))[0]["Floating IP Address"]' )
    if [ -n "$floatip" ]; then
	_do openstack server add floating ip $vm_id $floatip
	_do ssh-keygen -f ~/.ssh/known_hosts -R $floatip
	printf "# not added - DIY\n  cat >> ~/.ssh/config\n\nHost %s\nHostname %s\nIdentityFile ~/.ssh/keypairs/%s\n\n" \
	       "${vmname##${USER}-}" "$floatip" "$key_name"
    else
	echo Could not find a floating IP, will try to make one for next time
	floatnet_id=$( echo "$float_info" | jq '.[0]["Floating Network"]' )
	openstack floating ip create -f json $floatnet_id
	echo ...could go round again, did not bother
    fi
else
    echo did not see vm id
fi
