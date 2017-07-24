#!/bin/bash
#
# Simple script for creating backups with Duplicity.


# Set protocol (use scp for sftp and ftp for FTP, see manpage for more)


if [ $BPASSWORD ]; then
 BAC="$BPROTO://$BUSER:$BPASSWORD@$BHOST"
else
 BAC="$BPROTO://$BUSER@$BHOST"
fi


if [ "$BHOST" != '' ]; then
  BHOST="$BHOST"
else
  BHOST=''
fi


# set user and hostname of backup account

# Setting the password for the Backup account that the
# backup files will be transferred to.
# for sftp a public key can be used, see:
# http://wiki.hetzner.de/index.php/Backup
#BPASSWORD='yourpass'

# directories to backup (use . for /)
# . for / is not supported anymore in this script, because creating dirctories don't work on dropbox

LOGDIR='/var/log/duplicity'

TARGET='/bak/restore/'

echo "Parameter"
echo $0
echo $1

if [ -n "$0" ]; then
   RESTOREDIR=$TARGET$1
   shift
else
   RESTOREDIR="$TARGET/restored"
fi

echo "Restoring to: " 
echo $RESTOREDIR
echo "Using Parameters: "
echo $@


# Setting the pass phrase to encrypt the backup files. Will use symmetrical keys in this case.

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

echo "Restore from  $BAC"



FILEPREFIX="bak-"

#CMD="duplicity --allow-source-mismatch --file-prefix=$FILEPREFIX -v1 $GPGOPT  $BAC  $RESTOREDIR $@ "
#echo $CMD
#eval  $CMD



for DIR in $BDIRS
do

  # do a backup
#  if [ $DIR = '.' ]; then
#    CMD="duplicity --allow-source-mismatch $TYPE $VOLSIZE -v5 $GPGOPT $EXCLUDE /bak/ #$BAC/$BPREFIX-system >> $LOGDIR/system.log"
#  else
#    CMD="duplicity --allow-source-mismatch $TYPE $VOLSIZE -v5 $GPGOPT $EXCLUDE /bak/$DIR $BAC/$BPREFIX-$DIR >> $LOGDIR/$DIR.log"
#  fi
#--file-prefix=$FILEPREFIX
  CMD="duplicity --allow-source-mismatch  -v1 $GPGOPT $BAC/$BPREFIX-$DIR $RESTOREDIR $@ "
  echo $CMD

  eval  $CMD

done






# Check the manpage for all available options for Duplicity.
# Unsetting the confidential variables
unset PASSPHRASE

exit 0
