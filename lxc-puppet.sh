#!bash

set -e

usage()
{
	cat <<-EOF
	$1 -h|--help --puppet=<puppet server>

	Parameters:
	  -h                Show this help
	  -puppet=server    Puppet server URI
	EOF
	return 0
}

options=$(getopt -o h -l puppet: -- "$@")
if [ $? -ne 0 ]; then
	usage $(basename $0)
	exit 1
fi
eval set -- "$options"

while true
do
	case "$1" in
		-h|--help)  usage $0 && exit 0;;
		--puppet)   puppetserver=$2; shift 2;;
		--)         shift 1; break ;;
		*)          break ;;
	esac
done

apt-get update
apt-get -y install puppet

PUPPETPARAM=""
if [ "x${puppetserver}" != "x" ]; then
	PUPPETPARAM+="--server ${puppetserver} "
fi

puppet agent -tdv --waitforcert 60 ${PUPPETPARAM}
