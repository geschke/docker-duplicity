#!/bin/bash
set -e

[[ -n $DEBUG_ENTRYPOINT ]] && set -x


VAR_COMPLETE=1 
complete_index=0

if [ ! -z "$BCHECKS" ] && [ "$BCHECKS" == "false" ] ;
then
  echo "Bypass configuration variable checks"
else
  # Check environment for configuration of backup/restore script
  if [ -z "$BUSER" ] ; 
  then 
    echo "Backup User (BUSER) variable not defined." ; 
    VAR_COMPLETE=0
  fi
  if [ -z "$BHOST" ] ; 
  then 
    echo "Backup host (BHOST) variable not defined." ; 
    VAR_COMPLETE=0
  fi
  if [ -z "$BPASSWORD" ] ; 
  then 
    echo "Backup host password (BPASSWORD) variable not defined." ; 
    VAR_COMPLETE=0
  fi
  if [ -z "$BDIRS" ] ; 
  then 
    echo "Backup Directories (BDIRS) variable not defined." ; 
    VAR_COMPLETE=0
  fi
  if [ -z "$BPREFIX" ] ; 
  then 
    echo "Backup prefix (BPREFIX) variable not defined." ; 
    VAR_COMPLETE=0
  fi
  if [ -z "$BPROTO" ] ; 
  then 
    echo "Backup protocol (BPROTO) variable not defined." ; 
    VAR_COMPLETE=0
  fi
  if [ -z "$GPG_PASSPHRASE" ] ; 
  then 
    echo "GPG Passphrase (GPG_PASSPHRASE) variable not defined." ; 
    VAR_COMPLETE=0
  fi

  if [ "$VAR_COMPLETE" != 1 ]; then
    echo "Configuration variables missing, please see above error message! Stopped."
    exit 1
  else
    echo "Configuration complete."
  fi

fi



if [ "$BPREFIX" != '' ]; then
  BPREFIX="$BPREFIX"
else
  BPREFIX='backup'
fi
export BPREFIX


appBackup () {
  echo "Backup..."
  echo $@
  shift 1
  exec /usr/local/bin/backup.sh "$@"
}


appRestore () {
  echo "Restore..."
  echo $@
  shift 1
  exec /usr/local/bin/restore.sh "$@"
}

appHelp () {
  echo "Available options:"
  echo " backup          - Start the backup"
  echo " restore         - Start the restore"
  echo " [command]       - Execute the specified linux command eg. bash."
}

echo "in entrypoint:"
echo $@

case ${1} in
  backup)
    appBackup $@
    ;;
  restore)
    appRestore $@
    ;;
  help)
    appHelp
    ;;   
  *)
    if [[ -x $1 ]]; then
      $1
    else
      prog=$(which $1)
      if [[ -n ${prog} ]] ; then
        shift 1
        $prog "$@"
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0