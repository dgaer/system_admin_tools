#!/bin/bash

NET=$1
MASK=$2

LOGdir="${HOME}/logs"

if [ "${NET}" == "" ]
then 
    echo "ERROR - you must enter a network and mask"
    echo "${0} 10.1.5.0 255"
    exit 1
fi

if [ "${MASK}" == "" ]
then 
    echo "ERROR - you must enter a network and mask"
    echo "${0} 10.1.5.0 255"
    exit 1
fi

mkdir -p ${LOGdir}
LOGfile="${LOGdir}/pingscan_${NET}_${MASK}.txt"

oct1=$(echo "${NET}" | awk -F. '{ print $1 }')
oct2=$(echo "${NET}" | awk -F. '{ print $2 }')
oct3=$(echo "${NET}" | awk -F. '{ print $3 }')

count=$(echo "${NET}" | awk -F. '{ print $4 }')
let count=count+1

NUM=$(echo "255-${MASK}" | bc)
if [ $NUM -eq 0 ]; then NUM=255; fi

cat /dev/null > ${LOGfile}

echo "IP ADDRESS, STATUS, HOSTNAME, MAC ADDRESS" | tee -a ${LOGfile}
while [ $count -lt $NUM ]
do
    alive=$(ping -c 1 -w 1 $oct1.$oct2.$oct3.$count | grep ' bytes from ' | awk '{ print $4}')
    if [ "${alive}" != "" ]
	then
	host=$(echo $alive | sed s/://g)
	ARP=$(arp -a $oct1.$oct2.$oct3.$count)
	HOSTNAME=$(echo "${ARP}" | awk '{ print $1 }')
	MAC=$(echo "${ARP}" | awk '{ print $4 }')
	echo "${host}, UP, ${HOSTNAME}, ${MAC}" | tee -a ${LOGfile}
    else
	host="${oct1}.${oct2}.${oct3}.${count}"
	HOSTNAME=$(host $oct1.$oct2.$oct3.$count | grep -v 'not found')
	if [ "${HOSTNAME}" == "" ]; then HOSTNAME="NONE"; fi
	MAC="NONE"
	echo "${host}, DOWN, ${HOSTNAME}, ${MAC}" | tee -a ${LOGfile}
    fi
    let count=count+1
done

exit 0
