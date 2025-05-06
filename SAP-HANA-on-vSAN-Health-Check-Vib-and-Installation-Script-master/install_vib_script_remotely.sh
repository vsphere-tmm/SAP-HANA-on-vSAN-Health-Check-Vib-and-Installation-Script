#!/bin/sh
# Version 1.9.0
# Tested on vSphere 7 and vSphere 8
# Script to install/update/remove VIB and set /usr/lib/vmware/vsan/bin/setvSANInfo.py to cronjob
# Copyright (C) 2025 VMWare LLC by Broadcom <Chen WEI chen.wei@broadcom.com>

basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PING_TIMEOUT=2
PING_RETRY=3
SCRIPT_NAME=""
for VIB in `ls $basedir | grep setInfo`; do
	SCRIPT_NAME=$VIB
done

PYC="$basedir"/"$SCRIPT_NAME"
RUN_PYC_INTERVAL=5
TMP_PWD=$(mktemp)
DEST_PATH="/tmp"
METHOD=""
key=$1

display_usage() { 
	echo "Please specify the one of the following parameters:" 
	echo "-i or --install: install the vib on specified hosts"
	echo "-r or --remove: remove the vib on specified hosts"
	echo "-u or --update: update the vib on specified hosts"
	echo "-h or --help: display this message"
}

if [  $# -le 0 ] 
then
	display_usage
	exit 1
fi  

case $key in
    -i|--install)
    METHOD="install"
	;;
    -r|--remove)
    METHOD="remove"
	;;
    -u|--update)
    METHOD="update"
	;;
    -h|--help)
    display_usage
    exit 0
    ;;
    *)    # unknown option
    display_usage
    exit 1
    ;;
esac

sighandler() {
    rm "$TMP_PWD" -f
}
trap 'sighandler' SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGALRM SIGTERM

function host_accessible {
        HOST="$1"
        ping $HOST -c "$PING_RETRY" -W "$PING_TIMEOUT" > /dev/null 2>&1
        if [ $? != 0 ]
        then
                echo "$HOST is not reachable, please check the host name or network connectivity"
                rm "$TMP_PWD" -f
                exit 1
        fi
}

echo "Please specify the hosts(Separate by whitespace):"
read HOSTS
#Read User Name:
echo -n "login as: "
read USER
# Read Password
echo -n "Password: "
read -s password
echo


set -- $HOSTS
args=("$@")
ELEMENTS=${#args[@]}

if [ ${METHOD} == "install" ];
then
for ((j=0;j<$ELEMENTS;j++)); do
        echo "echo '$password'" > "$TMP_PWD"
        chmod 777 "$TMP_PWD"
        export SSH_ASKPASS="$TMP_PWD"
        [ "$DISPLAY" ] || export DISPLAY=dummydisplay:0

        HOST=${args[${j}]}
        echo 
        echo "Validating connectivity to ${HOST}"
        host_accessible $HOST
        echo "${HOST} connectivity validated"
        echo 

        echo "Uploading ${SCRIPT_NAME} to ${HOST}"
        setsid scp -o "StrictHostKeyChecking=no" "$PYC" "$USER"@"$HOST":"${DEST_PATH}"
        if [ $? != 0 ]
            then
            echo "Failed to upload ${SCRIPT_NAME} to ${HOST}"
            rm "$TMP_PWD" -f
            exit 1
        else 
            echo "Successfully uploaded ${SCRIPT_NAME} to ${HOST}:${DEST_PATH}"
        fi
        echo 
        echo "Installing VIB in ${HOST}"
        setsid ssh "$USER"@"$HOST" "localcli software vib install -v /tmp/${SCRIPT_NAME}"
        if [ $? != 0 ]
            then
            echo "Failed to install VIB in ${HOST}"
            rm "$TMP_PWD" -f
            exit 1
        else 
            echo "Successfully installed VIB in ${HOST}"
        fi
rm "$TMP_PWD" -f
done
elif [ ${METHOD} == "update" ]; then
for ((j=0;j<$ELEMENTS;j++)); do
        echo "echo '$password'" > "$TMP_PWD"
        chmod 777 "$TMP_PWD"
        export SSH_ASKPASS="$TMP_PWD"
        [ "$DISPLAY" ] || export DISPLAY=dummydisplay:0

        HOST=${args[${j}]}
        echo 
        echo "Validating connectivity to ${HOST}"
        host_accessible $HOST
        echo "${HOST} connectivity validated"
        echo 

        echo "Uploading ${SCRIPT_NAME} to ${HOST}"
        setsid scp -o "StrictHostKeyChecking=no" "$PYC" "$USER"@"$HOST":"${DEST_PATH}"
        if [ $? != 0 ]
            then
            echo "Failed to upload ${SCRIPT_NAME} to ${HOST}"
            rm "$TMP_PWD" -f
            exit 1
        else 
            echo "Successfully uploaded ${SCRIPT_NAME} to ${HOST}:${DEST_PATH}"
        fi
        echo 
        echo "Updating VIB in ${HOST}"
        setsid ssh "$USER"@"$HOST" "localcli software vib update -v /tmp/${SCRIPT_NAME}"
        if [ $? != 0 ]
            then
            echo "Failed to update VIB in ${HOST}"
            rm "$TMP_PWD" -f
            exit 1
        else 
            echo "Successfully update VIB in ${HOST}"
        fi
rm "$TMP_PWD" -f
done
else
for ((j=0;j<$ELEMENTS;j++)); do
        echo "echo '$password'" > "$TMP_PWD"
        chmod 777 "$TMP_PWD"
        export SSH_ASKPASS="$TMP_PWD"
        [ "$DISPLAY" ] || export DISPLAY=dummydisplay:0

        HOST=${args[${j}]}
        echo 
        echo "Validating connectivity to ${HOST}"
        host_accessible $HOST
        echo "${HOST} connectivity validated"
        echo 

        echo "Removing VIB in ${HOST}"

        setsid ssh "$USER"@"$HOST" 'pnum=`/bin/esxcli software vib list | grep setInfo | wc -l`; if [ $pnum == "1" ]; then localcli software vib remove -n setInfo;fi'
      
        if [ $? != 0 ]
            then
            echo "Failed to uninstall vib in ${HOST}"
            rm "$TMP_PWD" -f
            exit 1
        else 
            echo "Successfully cleared up VMs info, removed vib from ${HOST}"
        fi
done
fi
