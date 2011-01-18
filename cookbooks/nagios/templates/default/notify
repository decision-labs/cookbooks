#!/bin/bash

BASE_URL="https://<%= node[:fqdn] %>/nagios"
FROM="nagios <<%= node[:nagios][:from_address] %>>"
RCPT="${NAGIOS_CONTACTALIAS} <${NAGIOS_CONTACTEMAIL}>"

if [[ $1 == "host" ]]; then
	URL="${BASE_URL}/cgi-bin/extinfo.cgi?type=1&host=${NAGIOS_HOSTNAME}"
	SUBJECT="Host ${NAGIOS_NOTIFICATIONTYPE}: ${NAGIOS_HOSTNAME} is ${NAGIOS_HOSTSTATE}"
	CONTENT="State: ${NAGIOS_HOSTSTATE}Info: ${NAGIOS_HOSTOUTPUT}"

	if [[ ${NAGIOS_NOTIFICATIONTYPE} == "ACKNOWLEDGEMENT" ]]; then
		CONTENT="${CONTENT}Comment by ${NAGIOS_HOSTACKAUTHOR}:${NAGIOS_HOSTACKCOMMENT}"
	fi
else
	URL="${BASE_URL}/cgi-bin/extinfo.cgi?type=2&host=${NAGIOS_HOSTNAME}&service=${NAGIOS_SERVICEDESC}"
	SUBJECT="Service ${NAGIOS_NOTIFICATIONTYPE}: ${NAGIOS_HOSTNAME}/${NAGIOS_SERVICEDESC} is ${NAGIOS_SERVICESTATE}"
	CONTENT="Service: ${NAGIOS_SERVICEDESC}State: ${NAGIOS_SERVICESTATE}Additional Info:${NAGIOS_SERVICEOUTPUT}"

	if [[ ${NAGIOS_NOTIFICATIONTYPE} == "ACKNOWLEDGEMENT" ]]; then
		CONTENT="${CONTENT}Comment by ${NAGIOS_SERVICEACKAUTHOR}:${NAGIOS_SERVICEACKCOMMENT}"
	fi
fi

MAIL_BODY="From: ${FROM}
To: ${RCPT}
Subject: ** ${SUBJECT} **

***** nagios *****

Notification Type: ${NAGIOS_NOTIFICATIONTYPE}
Date/Time: ${NAGIOS_LONGDATETIME}
Host: ${NAGIOS_HOSTNAME} (${NAGIOS_HOSTADDRESS})
URL: ${URL}

${CONTENT}
"

/usr/sbin/sendmail -t -f "<%= node[:nagios][:from_address] %>" <<< "${MAIL_BODY}"
