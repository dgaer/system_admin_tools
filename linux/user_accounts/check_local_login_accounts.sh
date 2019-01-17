#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6, 7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 05/17/2018
# Date Last Modified: 10/29/2018
#
# Version control: 1.12
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Check Linux system for local login accounts
# OUTPUT is a CSV file
# Fields:
# username,description,UID,GID,group memberships,home directory,login shell,date password last changed,max days for password change,date password expires,days left until password expires, report time
# ----------------------------------------------------------- 

if [ "$(whoami)" != "root" ]; then
    echo "ERROR - You must be root to run this script"
    exit 1
fi

USERS=$(cat /etc/passwd | grep -v -E '^#' | grep -v -E '^$' | grep -v -E ':/.*/nologin$' | grep -v -E ':/sbin/shutdown$' | grep -v -E ':/bin/sync$' | grep -v -E ':/sbin/halt$' | awk -F: '{ print $1 }')
num=0

OUTFILE=/tmp/local_login_accounts.csv
cat /dev/null > ${OUTFILE}

echo "Checking $(hostname) for all local login users accounts" >&2
echo "" >&2
echo "user,description,UID,GID,groups,home,shell,pw changed,max days,pw expires,days left, report time" >&2

for u in ${USERS}
do
    salt_pw_hash=$(grep -E "^${u}:" /etc/shadow |  awk -F: '{ print $2 }')
    if [ "${salt_pw_hash}" == '*' ]; then continue; fi
    if [ "${salt_pw_hash}" == '!!' ]; then continue; fi
    pw_last_changed_days=$(grep -E "^${u}:" /etc/shadow |  awk -F: '{ print $3 }')
    if [ "${pw_last_changed_days}" == "" ]; then pw_last_changed_days="-1"; fi
    count=0
    for s in ${pw_last_changed_days}; do let count=count+1; done
    if [ ${count} -ne 1 ]; then
	echo "${u},ERROR - duplicate shadow file entry,-1,-1,ERROR,ERROR,ERROR,-1,-1,-1,-1,$(date +%s)" >&2
	continue
    fi
    pw_expires_days=$(grep -E "^${u}:" /etc/shadow |  awk -F: '{ print $5 }')
    if [ "${pw_expires_days}" == "" ]; then pw_expires_days="-1"; fi
    pw_last_changed=$(date -d "01/01/1970 +${pw_last_changed_days}days" +%m/%d/%Y)
    days_to=$(echo "${pw_last_changed_days} + ${pw_expires_days}" | bc)
    pw_expires=$(date -d "01/01/1970 +${days_to}days" +%m/%d/%Y)
    etime=$(date +%s)
    current_day=$(echo "${etime} / ((60*60)*24)" | bc)
    days_left=$(echo "${current_day} - ${pw_last_changed_days}" | bc)
    days_to_expire=$(echo "${pw_expires_days} - ${days_left}" | bc)
    if [ ${days_to_expire} -lt 0 ]; then days_to_expire=0; fi
    USRUID=$(grep -E "^${u}:" /etc/passwd |  awk -F: '{ print $3 }')
    count=0
    for s in ${USRUID}; do let count=count+1; done
    if [ ${count} -ne 1 ]; then
	echo "${u},ERROR - duplicate passwd file entry,-1,-1,ERROR,ERROR,ERROR,-1,-1,-1,-1,$(date +%s)" >&2
	continue
    fi
    USRGID=$(grep -E "^${u}:" /etc/passwd |  awk -F: '{ print $4 }')
    DESC=$(grep -E "^${u}:" /etc/passwd |  awk -F: '{ print $5 }')
    HOMEDIR=$(grep -E "^${u}:" /etc/passwd |  awk -F: '{ print $6 }')
    USRSHELL=$(grep -E "^${u}:" /etc/passwd |  awk -F: '{ print $7 }')
    USRGROUPS=$(grep ${u} /etc/group | grep -v -E '^#' | awk -F: '{ print $1 }')
    # Should have no space in this field
    USRUID=$(echo "${USRUID}" | sed s/' '//g)
    USRGID=$(echo "${USRGID}" | sed s/' '//g)
    HOMEDIR=$(echo "${HOMEDIR}" | sed s/' '//g)
    USRSHELL=$(echo "${USRSHELL}" | sed s/' '//g)
    USRGROUPS=$(echo "${USRGROUPS}" | sed s/' '//g)
    # Clean up the description field
    DESC=$(echo "${DESC}" | sed s/','/' '/g)
    DESC=$(echo "${DESC}" | sed s/"'"//g)
    if [ "${DESC}" == "" ]; then DESC="NONE"; fi

    echo -n "${u},${DESC},${USRUID},${USRGID}," | tee -a ${OUTFILE}
    count=0
    for g in ${USRGROUPS}; do let count=count+1; done
    i=0
    for g in ${USRGROUPS}
    do
	let i=i+1
	echo -n "${g}" | tee -a ${OUTFILE}
	if [ $i -lt $count ]; then echo -n ":" | tee -a ${OUTFILE}; fi
    done

    if [ "${pw_last_changed_days}" == "-1" ] || [ "${pw_expires_days}" == "-1" ]; then
	if [ "${pw_last_changed_days}" == "-1" ]; then 
	    echo ",${HOMEDIR},${USRSHELL},-1,-1,-1,-1,$(date +%s)" | tee -a ${OUTFILE}
	fi
	if [ "${pw_expires_days}" == "-1" ]; then 
	    echo ",${HOMEDIR},${USRSHELL},${pw_last_changed},-1,-1,-1,$(date +%s)" | tee -a ${OUTFILE}
	fi
    else
	echo ",${HOMEDIR},${USRSHELL},${pw_last_changed},${pw_expires_days},${pw_expires},${days_to_expire},$(date +%s)" | tee -a ${OUTFILE}
    fi
    let num=num+1
done

echo "" >&2
echo "$(hostname) has ${num} login users accounts" >&2
echo "" >&2

exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 
