#!/bin/sh

DOCKER_NAME="oddpoet/mesos-slave"

echo "###########################################################"
echo "                    Mesos-Slave"
echo "###########################################################"
echo 

exit_with_usage() {
	echo "Usage: docker run DOCKER_OPTS ${DOCKER_NAME} OPTIONS"
	echo 
	echo "Options:"
	echo "  -p,  --port=5051                   mesos slave port"
	echo "  --zk=zk://zk-server:2181/mesos     zookeper url"
	echo "  --help                             help message"
	echo 
	echo "Example: "
	echo "    docker run \\"
	echo "         -d -p 5051:5051 -h mesos-slave\\"
	echo "         ${DOCKER_NAME} -p 5051"
	exit 1
}

# parse option
while [[ $# > 0 ]];do 
	arg="$1"
	shift
	case $arg in 
		--zk=*)
			zk=${arg#*=}
			;;
		--port=*)
			port=${arg#*=}
			;;
		-p)
			port=$1
			shift
			;;
		--help)
			exit_with_usage
			;;
		*)
			exit_with_usage
			;;
	esac
done

# default 
port=${port:-5051}
zk=${zk:-"zk://zk-server:2181/mesos"}

# check
if [[ ! ("$port" =~ (^[0-9]+$)) ]];then 
	echo "> wrong port : $port"
	echo 
	exit_with_usage
fi

if [[ ! ("$zk" =~ (zk\://.+/.+)) ]];then 
	echo "> wrong zookeeper url : $zk"
	echo 
	exit_with_usage
fi

echo "* starting mesos (slave) "
echo "* port : $port"
echo "* zookeeper : $zk"

# set zk.
echo $zk > /etc/mesos/zk 

#start slave 
echo "$port" > /etc/mesos-slave/port
mesos-init-wrapper slave
