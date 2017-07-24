# geschke/docker-duplicity

This is a docker image to create backups and do restore with the **[duplicity](http://duplicity.nongnu.org/)** backup tool and a minimal backup shell script.

## Usage

To download the container run

    docker pull geschke/duplicity

It is a general-purpose Duplicity image with simple backup and restore scripts to handle the main tasks. It is based on the "[Backup Script for Duplicity](https://wiki.hetzner.de/index.php/Duplicity_Script/en)", published as part of the Hetzner DokuWiki. 

## Concepts


## Standard tasks 


### Backup 



### Restore



### Run any (Duplicity) command

I cannot guarantee that the scripts do fit all your needs. Furthermore, they are not tested under all circumstances and with all protocols which does Duplicity support. 
If you don't want to use the predefined tasks, then you have to dive deeper in the manual pages of Duplicity. There are plenty of options and tasks. To bypass the configuration variables checks, please add the environment variable `-e BCHECKS=false` to the Docker run command:

    docker run -it --rm --name duprun -e "BCHECKS=false" --volume /etc:/bak/etc --volume /home:/bak/home duplicity duplicity --help



## More Info



## See also

  * [duplicity man](http://duplicity.nongnu.org/duplicity.1.html) page
  * [duplicity back-up how-to - Ubuntu](https://help.ubuntu.com/community/DuplicityBackupHowto)
  * [How To Use Duplicity with GPG to Securely Automate Backups on Ubuntu | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu)
  * [Hetzner DokuWiki](https://wiki.hetzner.de/index.php/Hauptseite/en)


## Feedbacks

Report issues/questions/feature requests on [GitHub Issues](https://github.com/geschke/docker-duplicity/issues).