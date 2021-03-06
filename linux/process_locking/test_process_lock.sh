#!/bin/bash

trap ExitProc SIGHUP SIGINT SIGTERM SIGQUIT SIGABRT
# 0  - exit from shell
# 1  - SIGHUP
# 2  - SIGINT (Control -C)
# 3  - SIGQUIT
# 6  - SIGABRT
# 9  - SIGKILL (kill -9)
# 14 - SIGALRM
# 15 - SIGTERM (kill)

function ExitProc() {
    echo "$PROGRAMname has been signaled to terminate"
    echo "Running clean-up and exit proceedure"
    rm -f $LOCKfile 
    echo "Exiting..."
    exit 1
}

source ./process_lock.sh

PROGRAMname="$0"
LOCKfile="process_lock.lck"
MINold="0"

LockFileCheck $MINold

echo "Testing process locking script"

echo "Creating lock file"
CreateLockFile

echo "Staring test"
echo "Looping forever..."
# Loop forever
while :
do
  sleep 9999
done

RemoveLockFile

