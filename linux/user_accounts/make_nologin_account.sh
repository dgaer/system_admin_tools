#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6, 7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 10/17/2018
# Date Last Modified: 10/17/2018
#
# Version control: 1.03
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to switch a login account to a no login account 
#
# ----------------------------------------------------------- 

if [ "$(whoami)" != "root" ]; then
    echo "ERROR - You must be root to run this script"
    exit 1
fi

USERNAME=${1}

if [ "${USERNAME}" == "" ]; then
    echo "ERROR - You must supply a username or space seperated list of usernames" 
    echo "USAGE 1: ${0} username"
    echo "USAGE 2: ${0} 'user1 user2 user3 user4'"
    exit 1
fi

for u in  ${USERNAME}; do
    echo "Switching user account ${u} to a  no login  account"
    grep -E "^${u}:" /etc/passwd &> /dev/null
    if [ $? -ne 0 ]; then 
	echo "ERROR - User ${u} not found on $(hostname)"
	exit 1;
    fi
    
    passwd -d ${u}
    passwd -l ${u}
    usermod -s /sbin/nologin ${u}
    chage -m 0 -M 99999 -I -1 -E -1  ${u}
    
    DESC=$(grep -E "^${u}:" /etc/passwd |  awk -F: '{ print $5 }')
    echo "${DESC}" | grep 'No Login Account'
    if [ $? -ne 0 ]; then 
	DESC=$(echo "${DESC}" | sed s/','/' '/g)
	DESC=$(echo "${DESC}" | sed s/"'"//g)
	if [ "${DESC}" != "" ]; then
	    COMMENTS=$(echo "$DESC No Login Account")
	else
	    COMMENTS=$(echo "No Login Account")
	fi
	usermod -c "${COMMENTS}" ${u}
    fi
done

exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 
