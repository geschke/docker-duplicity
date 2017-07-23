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

if [ -n "$1" ]; then
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
PASSPHRASE='i'
export PASSPHRASE

# encryption algorithm for gpg, disable for default (CAST5)
# see available ones via 'gpg --version'
ALGO=AES

VOLSIZE="--volsize=1000"

##############################


if [ $ALGO ]; then
 GPGOPT="--gpg-options '--pinentry-mode loopback --cipher-algo $ALGO'"
fi

BAC="$BPROTO$BPREFIX/$BHOST"

echo "Restore from  $BAC"



FILEPREFIX="bak-"

CMD="duplicity --allow-source-mismatch --file-prefix=$FILEPREFIX -v1 $GPGOPT  $BAC  $RESTOREDIR $@ "
#echo $CMD
eval  $CMD


# Check the manpage for all available options for Duplicity.
# Unsetting the confidential variables
unset PASSPHRASE

exit 0
