#!/bin/bash
#
# Initialize new virtual server using LXC and set up networking
#
# Written by: Martin Malek <tmp2009@marten-online.com>
#
# Released into Public Domain. You may use, modify and distribute it as you
# see fit.
#
# This script will:
#  1. Create a new LXC virtual machine based on the template
#  2. Allocate an IP address on the LXC network (must be /24) for the new vm
#  3. Start the new VM

set -e

#if [[ $(/usr/bin/id -u) -ne 0 ]]; then
#	echo "Script needs to be run as root";
#	exit 1;
#fi

usage()
{
	cat <<-EOF
	$1 [-h|--help] [--template=<template name>] [--config=<config file path>] [--domain=<domain>] <container name>

	Parameters:
	  -h                  Show this help
	  --template=template Template name, default 'debian'
	  --config=file       Config file path, default '/usr/share/doc/lxc/examples/lxc-veth.conf'
	  --domain=domain     Domain suffix for the container, default '.lan'
	EOF
	return 0
}

options=$(getopt -o ht:d:c: -l help,template:,domain:,config:,n: -- "$@")
eval set -- "$options"

while true
do
	case "$1" in
		-h|--help)     usage $0 && exit 0;;
		-t|--template) lxc_template=$2; shift 2;;
		-d|--domain)   domain_suffix=$2; shift 2;;
		-c|--config)   lxc_config=$2; shift 2;;
		--)            shift 1; break ;;
		*)             break ;;
	esac
done

lxc_template=${lxc_template:-"debian"}
lxc_config=${lxc_config:-"/usr/share/doc/lxc/examples/lxc-veth.conf"}
domain_suffix=${domain_suffix:-"lan"}

if [ $# -ne 1 ]; then
	usage $(basename $0)
	exit 1;
fi

# container name
name=$1

if [ -d /var/lib/lxc/$name/ ]; then
	echo "Container named $name already exists."
	exit 1;
fi

lxc-create -n $name -t ${lxc_template} -f ${lxc_config}

## set up networking
macAddress=`grep "lxc.network.hwaddr" /var/lib/lxc/$name/config | cut -d '=' -f 2 | tr -d ' '`
containerIP=`cat /var/lib/misc/dnsmasq.leases | grep ${macAddress}`
containerIP=${containerIP:-"DHCP"}

cat <<-EOF
New container $name created.
  Internal IP: $containerIp
EOF

## start the lxc container
read -p "Start ${name} container now? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	lxc-start -n $name -d
fi
