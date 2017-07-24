#!/bin/bash

#
#
# Simple script for creating backups with Duplicity.
# Full backups are made on the 1st day of each month or with the 'full' option.
# Incremental backups are made on any other days.
#
# USAGE: backup.sh [full]
#

echo "BPREFIX TEST:"
echo $BPREFIX

echo $BUSER
echo $BHOST
echo $BPASSWORD
echo $GPG_PASSPHRASE
echo "All:"
echo $@
echo $0
echo $1


# get day of the month
DATE=`date +%d`

# Set protocol (use scp for sftp and ftp for FTP, see manpage for more)
#BPROTO=scp

# set user and hostname of backup account
#BUSER='u10000'
#BHOST='u10000.your-backup.de'

# Setting the password for the Backup account that the
# backup files will be transferred to.
# for sftp a public key can be used, see:
# http://wiki.hetzner.de/index.php/Backup


# directories to backup (use . for /)
#BDIRS="etc home srv ."
#TDIR=`hostname -s` now BPREFIX
LOGDIR='/var/log/duplicity'

# Setting the pass phrase to encrypt the backup files. Will use symmetrical keys in this case.
#GPGPASSPHRASE='yoursecretgpgpassphrase'


PASSPHRASE=GPG_PASSPHRASE
export PASSPHRASE

# encryption algorithm for gpg, disable for default (CAST5)
# see available ones via 'gpg --version'
ALGO=AES


VOLSIZE="--volsize=1000"


##############################

if [ $ALGO ]; then
 GPGOPT="--gpg-options '--pinentry-mode loopback --cipher-algo $ALGO'"
fi

if [ $BPASSWORD ]; then
 BAC="$BPROTO://$BUSER:$BPASSWORD@$BHOST"
else
 BAC="$BPROTO://$BUSER@$BHOST"
fi



# Check to see if we're at the first of the month.
# If we are on the 1st day of the month, then run
# a full backup. If not, then run an incremental
# backup.

if [ $DATE = 01 ] || [ "$1" = 'full' ]; then
 TYPE='full'
else
 TYPE='incremental'
fi

for DIR in $BDIRS
do
  if [ $DIR = '.' ]; then
    EXCLUDELIST='/duplicity/duplicity-exclude.conf'
  else
    EXCLUDELIST="/duplicity/duplicity-exclude-$DIR.conf"
  fi

  if [ -f $EXCLUDELIST ]; then
    EXCLUDE="--exclude-filelist $EXCLUDELIST"
  else
    EXCLUDE=''
  fi

  # first remove everything older than 2 months
  if [ $DIR = '.' ]; then
   CMD="duplicity remove-older-than 2M -v5 --force $BAC/$BPREFIX-system 
   # >> $LOGDIR/system.log"
  else
   CMD="duplicity remove-older-than 2M -v5 --force $BAC/$BPREFIX-$DIR 
   # >> $LOGDIR/$DIR.log"
  fi
  eval $CMD

  # do a backup
  if [ $DIR = '.' ]; then
    CMD="duplicity --allow-source-mismatch $TYPE $VOLSIZE -v5 $GPGOPT $EXCLUDE /bak/ $BAC/$BPREFIX-system 
    # >> $LOGDIR/system.log"
  else
    CMD="duplicity --allow-source-mismatch $TYPE $VOLSIZE -v5 $GPGOPT $EXCLUDE /bak/$DIR $BAC/$BPREFIX-$DIR
    # >> $LOGDIR/$DIR.log"
  fi
  eval  $CMD

done

# Check the manpage for all available options for Duplicity.
# Unsetting the confidential variables
unset PASSPHRASE
unset GPG_PASSPHRASE

exit 0