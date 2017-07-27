#!/bin/bash
#
# Simple script for restoring backups with Duplicity.



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


# directories to backup (use . for /)
# . for / is not supported anymore in this script, because creating dirctories don't work on dropbox

#LOGDIR='/var/log/duplicity'

TARGET='/bak/restore/'

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
 FTP_PASSWORD=$BPASSWORD
 export FTP_PASSWORD
 BAC="$BPROTO://$BUSER@$BHOST"
 #BAC="$BPROTO://$BUSER:$BPASSWORD@$BHOST"
else
 BAC="$BPROTO://$BUSER@$BHOST"
fi


for DIR in $BDIRS
do

  echo "Restore from  $BAC"

  CMD="duplicity --allow-source-mismatch  -v1 $GPGOPT $BAC/$BPREFIX-$DIR $RESTOREDIR/$DIR $@ "
  #echo $CMD
  eval  $CMD

done


# Check the manpage for all available options for Duplicity.
# Unsetting the confidential variables
unset PASSPHRASE
unset GPG_PASSPHRASE
unset FTP_PASSWORD

exit 0
