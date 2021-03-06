# geschke/duplicity

This is a docker image to create backups and do restore with the **[duplicity](http://duplicity.nongnu.org/)** backup tool and a minimal backup shell script.

## Usage

To download the container run

    docker pull geschke/duplicity

It is a general-purpose Duplicity image with simple backup and restore scripts to handle the main tasks. It is based on the "[Backup Script for Duplicity](https://wiki.hetzner.de/index.php/Duplicity_Script/en)", published as part of the Hetzner DokuWiki.

## Concepts

To use this image, it is important to understand the basic concepts of a Docker container. Per default, the applications inside the container have only access to the internal filesystem.
To access the directories and files you want to backup, they have to be mounted as volumes into the container.

Example:

    --volume /home:/bak/home

This option mountes the `/home` folder of the host into the container and makes it accessible as the folder `/bak/home`.

*Important*: The prefix `/bak` is fixed in the backup and restore scripts! You can mount as many folders as you like, but all of them have to build a structure in `/bak/`.


## Standard tasks



### Backup

To create a backup, the image comes with a simple and small shell script with some predefined assumptions. A typical task looks like this:

    docker run -it --rm --name dup \
    -e "GPG_PASSPHRASE=USE_A_GOOD_PASSPHRASE_HERE" \
    -e "BPROTO=ftp" \
    -e "BUSER=backup_user" \
    -e "BHOST=ftp.backup.host.example.com" \
    -e "BPASSWORD=backup_host_password" \
    -e "BDIRS=etc home" \
    -e "BPREFIX=hostname_or_another_prefix" \
    --volume /etc:/bak/etc \
    --volume /home:/bak/home \
    geschke/duplicity backup

The script relies on some environment variables. If you start this container, the existence of the environment variables is checked, but you are responsible to fill them with senseful content.

| Parameter | Description |
|-----------|-------------|
| `GPG_PASSPHRASE` | This is the GPG passphrase to encrypt the backup files. |
| `BPROTO` | The protocol scheme of the backup space server. Use `ftp` for FTP, `sftp` for sftp, have a look at the manpage of Duplicity for more info. |
| `BUSER` | The username of the backup account |
| `BHOST` | The hostname of the backup account |
| `BPASSWORD` | The password of the backup space |
| `BDIRS` | The directories in the mounted volumes to be backed up. Use the names of the volumes in the container, but without the prefix `/bak`. In the command above the folders `/bak/home` and `/bak/etc` will be backed up, so you have to use `etc home` here. The order of the names is not important. |
| `BPREFIX` | Use this to set a prefix for the backup files. Usually this could be the hostname of the server to be backed up. |

The script runs with the option to remove backups when they are older than 2 months.

You can do full backups by submitting the parameter *"full"*. Full backups are automatically created on the 1st day of each month. The *first* run has to be as *full* backup, so that the incremental backups could be built.

Example of full backup:

    docker run -it --rm --name dup \
    -e "GPG_PASSPHRASE=USE_A_GOOD_PASSPHRASE_HERE" \
    -e "BPROTO=ftp" \
    -e "BUSER=backup_user" \
    -e "BHOST=ftp.backup.host.example.com" \
    -e "BPASSWORD=backup_host_password" \
    -e "BDIRS=etc home" \
    -e "BPREFIX=hostname_or_another_prefix" \
    --volume /etc:/bak/etc \
    --volume /home:/bak/home \
    geschke/duplicity backup full


### Restore


To restore a backup, run the `restore` command:

    docker run -i --rm --name dup \
    -e "GPG_PASSPHRASE=USE_A_GOOD_PASSPHRASE_HERE" \
    -e "BPROTO=ftp" \
    -e "BUSER=backup_user" \
    -e "BHOST=ftp.backup.host.example.com" \
    -e "BPASSWORD=backup_host_password" \
    -e "BDIRS=etc home" \
    -e "BPREFIX=hostname_or_another_prefix" \
    --volume /srv/restored:/bak/restore \
    geschke/duplicity restore <folder>

The environment variables are the same as in the backup step.

In this example the restored folders `etc` and `home` will be placed into the folder `/srv/restored` on the host.
If you submit the optional *folder* parameter, the name of the folder will be concatenated to the dedfault restore folder name, so the files are stored into `/bak/restore/<folder>`.



### Run any (Duplicity) command

I cannot guarantee that the scripts do fit all your needs. Furthermore, they are not tested under all circumstances and with all protocols which does Duplicity support.
If you don't want to use the predefined tasks, then you have to dive deeper in the manual pages of Duplicity. There are plenty of options and tasks. To bypass the configuration variables checks, please add the environment variable `-e BCHECKS=false` to the Docker run command. The following example runs duplicity with `--help` to see the available options:

    docker run -it --rm --name duprun -e "BCHECKS=false" \
    --volume /etc:/bak/etc \
    --volume /home:/bak/home \
    geschke/duplicity duplicity --help

This command runs *duplicity* with *--help* as parameter, mounts the folders `/etc/` into `/bak/etc/` and `/home/` into `/bak/home/` and don't check more of the environment variables.


## SSH (SCP and SFTP) issues

By connecting a host with `scp` or `sftp` procotol, Duplicity will ask to accept the public key. It is recommended to receive the public key by a secure channel like directly from the admin. Nevertheless, if you accept the request and answer with "yes" to store the public key, the Docker container is built to be "ephemeral", so you can stop and destroy the container or run a new container with minimal setup. That means, that storing the server's public key into the container is a bad idea. 

To solve this, it is possible to mount a pre-generated known_hosts file into the container. The known_hosts file (usually stored in the user's `.ssh/` folder) contains the public keys of SSH servers. 
For `scp` and `sftp` connections, Duplicity usually makes use of the Python Paramiko library. Unfortunately, Paramiko needs another format of the public keys than most SSH clients offer. But you can generate the necessary format by the following command:

     ssh-keyscan -t rsa ftp.backup.host.example.com >> .ssh/known_hosts

This stores the public key into `.ssh/known_hosts`, feel free to use another or an extra file to handle with backup issues. 

At last, you have to make the known_hosts file accessible within the container:

    docker run -it --rm --name dup \
    -e "GPG_PASSPHRASE=USE_A_GOOD_PASSPHRASE_HERE" \
    -e "BPROTO=ftp" \
    -e "BUSER=backup_user" \
    -e "BHOST=ftp.backup.host.example.com" \
    -e "BPASSWORD=backup_host_password" \
    -e "BDIRS=etc home" \
    -e "BPREFIX=hostname_or_another_prefix" \
    --volume /etc:/bak/etc \
    --volume /home:/bak/home \
    --volume /home/user_on_host/.ssh/known_hosts:/root/.ssh/known_hosts \
    geschke/duplicity backup


Have a look at the last volume line - the `known_hosts` file is mounted into the container. For sure, you have to change the value of the host's user (here `user_on_host`).  


## See also

  * [duplicity man](http://duplicity.nongnu.org/duplicity.1.html) page
  * [duplicity back-up how-to - Ubuntu](https://help.ubuntu.com/community/DuplicityBackupHowto)
  * [How To Use Duplicity with GPG to Securely Automate Backups on Ubuntu | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu)
  * [Hetzner DokuWiki](https://wiki.hetzner.de/index.php/Hauptseite/en)


## Feedback

Report issues/questions/feature requests on [GitHub Issues](https://github.com/geschke/docker-duplicity/issues).