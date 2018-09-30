#!/bin/bash -e

source $(dirname "$0")/config.sh || echo "Create a config.sh containing TOKEN and USER keys from pushover"

STATUS=$(/sbin/apcaccess -p STATUS 2> /dev/null | awk '{print $1}')
BCHARGE=$(/sbin/apcaccess -p BCHARGE 2> /dev/null | awk '{print $1}')
TIMELEFT=$(/sbin/apcaccess -p TIMELEFT 2> /dev/null | awk '{print $1}')
LINEV=$(/sbin/apcaccess -p LINEV 2> /dev/null | awk '{print $1}')
OUTPUTV=$(/sbin/apcaccess -p OUTPUTV 2> /dev/null | awk '{print $1}')
LOADPCT=$(/sbin/apcaccess -p LOADPCT 2> /dev/null | awk '{print $1}')

MODEL=$(/sbin/apcaccess -p MODEL 2> /dev/null) # no trimming

if [ "${STATUS}" = "" ]; then
    MESSAGE="Could not connect to apcupsd"
else
    case "${MODEL}" in
	Smart-UPS*)
	    MESSAGE="Status: ${STATUS}"$'\n'"Battery: ${BCHARGE}%"$'\n'"Load: ${LOADPCT}%"$'\n'"Time left: ${TIMELEFT} min"$'\n'"Input: ${LINEV}V"$'\n'"Output: ${OUTPUTV}V"$'\n'
	    ;;
	Back-UPS*)
	    MESSAGE="Status: ${STATUS}"$'\n'"Battery: ${BCHARGE}%"$'\n'"Time left: ${TIMELEFT} min"$'\n'
	    ;;
    esac
fi

SEND=1

case ${STATUS} in
    ONLINE)
	if [ $(echo ${BCHARGE}|cut -d"." -f1) = "100" ]; then
	    SEND=0
	fi
	;;
esac

if [ "${1}" = "force" ]; then
    SEND=2
fi

if [ ${SEND} -gt 0 ]; then
    curl -s \
	 --form-string "token=${TOKEN}" \
	 --form-string "user=${USER}" \
	 --form-string "message=${MESSAGE}" \
	 https://api.pushover.net/1/messages.json > /dev/null
fi
