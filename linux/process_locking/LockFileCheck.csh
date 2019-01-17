#!/bin/csh
# ----------------------------------------------------------- 
# UNIX Shell Script File Name: LockFileCheck.csh
# Tested Operating System(s): RHEL 3, 4, 5
# Tested Run Level(s): 3, 5
# Shell Used: C shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 09/20/2007
# Date Last Modified: 08/07/2008
#
# Version control: 1.04
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Complex locking protocol functions for C shell, CSH, TCSH scripts
#
# This script is designed to be called from other scripts.
#
# NOTE: The C chell does not support POSIX style functions so the
# NOTE: locking scrtipts must be called from within an exiting
# NOTE: C shell sctipts.
#
#
# Before calling the lock file functions the caller must 
# define the following variables:
#
# PROGRAMname
# LOCKfile
# PROGRAMpid
# MINold
#
# The above variables must then be passed to the locking scripts
# as command line arguments.
# ----------------------------------------------------------- 

# Set the input variables

set PROGRAMname = "$0"
if ( "$1" != "" ) then 
  set PROGRAMname = "$1"
endif

set LOCKfile = "${PROGRAMname}.lck"
if ( "$2" != "" ) then 
  set LOCKfile = "$2"
endif

set PROGRAMpid = "$$"
if ( "$3" != "" ) then 
  set PROGRAMpid = "$3"
endif

set MINold = "60"
if ( "$4" != "" ) then 
  set MINold = "$4"
endif

# Complex locking protocol

if ( -e ${LOCKfile} ) then
  echo "A lock file exists: ${LOCKfile}"
    
  # Read the hostname and the PID from the lock file
  set LOCKhostname = `awk -F: '{ print $1 }' ${LOCKfile}`
  set LOCKpid = `awk -F: '{ print $2 }' ${LOCKfile}`

  # Check our current hostname
  set hostname = `hostname`
  if ( "$hostname" != "$LOCKhostname" ) then
    echo "Process is locked on another node $LOCKhostname"
    echo "Checking for lock file older than $MINold minutes"
    find ${LOCKfile} -mmin +$MINold -type f -print -exec rm -f {} \; > /dev/null 
    if ( -e ${LOCKfile} ) then
      echo "Lock file still exists: ${LOCKfile}"
      echo "Application may still be running or has terminated before completion"
      echo "Exiting..."
      exit 1
    endif
    echo "Removing the old lock file and continuing to run"
    exit 0 
  endif
  echo "Checking to see how long the process has been running"
  set currlockfile = `find ${LOCKfile} -mmin +$MINold -type f -print`
  if ( "${currlockfile}" == "${LOCKfile}" ) then
   echo "PID ${LOCKpid} has been running for more than $MINold minutes"
   set ispidvalid = `ps -e | grep ${LOCKpid} | grep -v grep | awk '{print $1}'`
   if ( "$ispidvalid" == "$LOCKpid" ) then
        echo "Attempting to kill the previous process ${LOCKpid} and any children"
	set pidlist = `ps -ef | grep $LOCKpid | grep -v grep | awk '{print $2}' | sort -rn`
	foreach pids($pidlist)
	  echo "Killing PID $pids"
	  set ispidvalid = `ps -ef | grep ${pids} | grep -v grep | awk '{print $2}'`
	  if ( "$ispidvalid" == "$pids" ) then
	     kill $pids
	  endif
	  # Check to see if the PID is still running
	  set ispidvalid = `ps -ef | grep ${pids} | grep -v grep | awk '{print $2}'`
	  if ( "$ispidvalid" == "$pids" ) then
	      echo "Could not kill process $pids for process ${LOCKpid}" 
	      echo "${LOCKpid}  process is still running" 
	      echo "Application may be running or has terminated before completion"
	      echo "Exiting..."
	      exit 1
	  endif
	end
        # Check for PIDs that respawned after killing a child 
        set pidlist = `ps -ef | grep $LOCKpid | grep -v grep | awk '{print $2}' | sort -rn`
        foreach pids($pidlist)
	   echo "Killing respawned PID $pids"
	   set ispidvalid = `ps -e | grep $pids | grep -v grep | awk '{print $1}'`
	   # Make sure the PID is still active are killing child process
	   if ( "$ispidvalid" == "$pids" ) then
	      kill $pids
	   endif
	   # Check to see if the PID is still running
	   set ispidvalid = `ps -ef | grep ${pids} | grep -v grep | awk '{print $2}'`
	   if ( "$ispidvalid" == "$pids" ) then
	      echo "Could not kill process $pids for process ${LOCKpid}" 
	      echo "${LOCKpid}  process is still running" 
	      echo "Application may be running or has terminated before completion"
	      echo "Exiting..."
	      exit 1
	  endif
	end
     else
	echo "PID ${LOCKpid} is not running"
	echo "Removing the old lock file and continuing to run"
	rm -f ${LOCKfile}
	exit 0
    endif
  endif
	
  # Check to see if the process is still running
  set ispidvalid = `ps -e | grep ${LOCKpid} | grep -v grep | awk '{print $1}'`
  echo "Checking to see if the previous process is still running"
  if ( "$ispidvalid" == "$LOCKpid" ) then
     echo "${LOCKpid}  process is still running" 
     echo "Application may be running or has terminated before completion"
     echo "Exiting..."
     exit 1
  endif

  echo "Previous process is not running"
  echo "Removing the old lock file and continuing to run"
  rm -f ${LOCKfile}
  exit 0  
endif

# There is no lock file
exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 


