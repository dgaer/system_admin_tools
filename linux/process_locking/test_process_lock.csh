#!/bin/csh

set BINdir = "."
set PROGRAMname = "$0"
set PROGRAMpid = "$$"
set LOCKfile = "process_lock.lck"
set MINold = "1"
set LockFunctionArgs = "${PROGRAMname} ${LOCKfile} ${PROGRAMpid} ${MINold}"
 
${BINdir}/LockFileCheck.csh ${LockFunctionArgs} 
if ( "$?" != "0") then 
    exit 
endif

echo "Testing process locking script"

echo "Creating lock file"
${BINdir}/CreateLockFile.csh ${LockFunctionArgs}

echo "Staring test"
echo "Sleeping..."
sleep 9999

${BINdir}/RemoveLockFile.csh ${LockFunctionArgs}


