#! /bin/sh

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

script_dir="$( dirname "$0" )"
vmname=pettle-tmp
image=bionic-WTSI-docker_b5612

# how mca sets up his openstack
unset http_proxy
unset https_proxy
unset no_proxy
unset PYTHONPATH
. $HOME/_py.sw361/bin/activate
. $HOME/openrc/casm-general-openrc.sh


if vm_create="$(

_do openstack server create \
	  --image $image --flavor o2.medium --key-name mca-eta \
	  $( _kvp --security-group cloudforms_local_in cloudforms_web_in default cloudforms_ext_in cloudforms_ssh_in ) \
	  --network casm-general-shared \
	  --format json \
	  --user-data "$script_dir/cloud-init.sh" \
	  --wait $vmname
)"; then

    vm_id=$( echo "$vm_create" | jq --raw-output .id )
    printf "\nCreated $vm_id ok\n\n%s\n" "$vm_create"
fi

if [ -n "$vm_id" ]; then
    echo Have host id=$vm_id
    float_info="$( _do openstack floating ip list -f json )"
    floatip=$( echo "$float_info" | jq --raw-output 'map(select(.Port | not))[0]["Floating IP Address"]' )
    if [ -n "$floatip" ]; then
	_do openstack server add floating ip $vm_id $floatip
	_do ssh-keygen -f ~/.ssh/known_hosts -R $floatip
    else
	echo Could not find a floating IP, will try to make one for next time
	floatnet_id=$( echo "$float_info" | jq '.[0]["Floating Network"]' )
	openstack floating ip create -f json $floatnet_id
	echo ...could go round again, did not bother
    fi
else
    echo did not see vm id
fi
