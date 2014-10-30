# FluidTYPO3 Vagrant

## What it does?
Create a Debian based Virtualbox VM and install TYPO3 and a few helper tools.

## Warning
This setup is only for local test setup. TrustedHostPattern is a wildcard.
Also this project is in a early state and you need to fill a issue report.

## Quick-start
Checkout the repo, edit Vagrantfile facters.
```vagrant up```
Domain is http://dev.fluidtypo3.org
Have fun :)

### Features
- Nginx 1.6.x
- MariaDB 10.1
- Postfix + Dovecot
- zsh with grml
- PHP-FPM
- github sources (TYPO3, Webgrind,Rouncubemail, phpMyAdmin, OpCacheGUI, FluidTYPO3)
- webgrind - xDebug profiler http://dev.fluidtypo3.org/webgrind (Add ?XDEBUG_PROFILE for a profile)
- phpMyAdmin - http://dev.fluidtypo3.org/phpMyAdmin
+ Opcache Stats (3 different tools)
    * Opcache http://dev.fluidtypo3.org/opcache.php
    * Opcache http://dev.fluidtypo3.org/opcache-dashboard.php
    * OpCacheGUI http://dev.fluidtypo3.org/OpCacheGUI
+ roundcubemail http://dev.fluidtypo3.org/webmail - All mails are send to development@localhost
    * Login via development Password password
- Cronjob for scheduler
- Codesniffer with FluidTYPO3 standard

### Codesniffer example
```shell
phpcs -n --standard=FluidTYPO3 --extensions=php /var/www/typo3conf/ext/builder
```

### Requirements
- Linux, Mac are tested
- For installation Internet connection with enough broadband
- We only test with the provider Virtualbox

### Credentials
TYPO3
- User: admin
- Password/Installtool: password

MySQL
- User: root
- Password: password

Database typo3
- User: typo3
- Password: password

Mail
- User: development
- Password: password

Vagrant shell
- User: vagrant
- Password: vagrant

### Contributing
Create a PR.


### FAQ

#### Do we support Windows as host?
- Windows needs to replace the NFS share with SMB or Virtualbox shared folder. Please take a look in [https://docs.vagrantup.com/v2/synced-folders/index.html] and change your Vagrantfile.

#### Initial download volume?
- First time 420 MB for cache vagrant box and 150 MB each complete vagrant up

#### Build time
- Depends on a lot of factors. HDD speed, connection speed<br />
```vagrant up``` ~7min 30sec (install/start VM + first provision 360 sec)<br />
```vagrant provision``` ~60 seconds

#### Any way to improve with a slow connection?
- Easiest way is cache or mirror the debian repository. This is also possible for git repository's.


### Warning
- Puppet Vscrepo is patched to allow depth with a branch option
- Puppet MySQL module is patched to allow Debian MariaDB
