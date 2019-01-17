#!/bin/csh
# ----------------------------------------------------------- 
# UNIX Shell Script File Name: CreateLockFile.csh
# Tested Operating System(s): RHEL 3, 4, 5
# Tested Run Level(s): 3, 5
# Shell Used: C shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 09/20/2007
# Date Last Modified: 01/22/2009
#
# Version control: 1.05
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

# Build a new lock file using "hostname:PID" format
set hostname = `hostname`
echo -n "${hostname}:" > ${LOCKfile}
echo -n ${PROGRAMpid} >> ${LOCKfile}
chmod 777 ${LOCKfile}

exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 
