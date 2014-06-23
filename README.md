# FluidTYPO3 Vagrant

## What it does?
Create a Debian based Virtualbox VM and install TYPO3 and a few helper tools.

## Warning
This setup is only for local test setup. TrustedHostPattern is a wildcard.
Also this project is in a early state and you need to fill a issue report.

## Quick-start
Checkout the repo, edit Vagrantfile facters.
```vagrant up```
Have fun :)

### Features
- Nginx 1.6.x
- MariaDB 10.1
- Postfix + Dovecot
- zsh with grml
- PHP-FPM
- github sources (TYPO3, Webgrind,Rouncubemail, phpMyAdmin, OpCacheGUI, FluidTYPO3)
- vagrant rsync (activate via ```vagrant rsync-auto```)
- webgrind - xDebug profiler http://host/webgrind (Add ?XDEBUG_PROFILE for a profile)
- phpMyAdmin - http://host/phpMyAdmin
+ Opcache Stats (3 different tools)
    * Opcache http://host/opcache.php
    * Opcache http://host/opcache-dashboard.php
    * OpCacheGUI http://host/OpCacheGUI
+ roundcubemail http://host/webmail - All mails are send to development@localhost
    * Login via development Password devel
- Cronjob for scheduler
- Codesniffer with FluidTYPO3 standard

### Codesniffer example
```shell
phpcs -n --standard=FluidTYPO3 --extensions=php /var/www/typo3conf/ext/builder
```

### Requirements
- Linux (tested) or Mac
- For installation Internet connection with enough broadband
- Only tested Virtualbox

### Credentials
TYPO3
- User: admin
- Password/Installtool: development

MySQL
- User: root
- Password: devel

Database typo3
- User: typo3
- Password: devel

### Contributing
Create a PR.


### FAQ

#### I have a problem with windows and vagrant.
- it should work, maybe you need rsync or alternatively comment out the rsync line

#### Initial download volume?
- Frist time 420 MB for cache vagrant box and 450 MB each complete vagrant up

#### Build time
- Depends on a lot of factors. HDD speed, connection speed<br />
```vagrant up``` ~8min 30sec (install/start VM + first provision 420 sec)<br />
```vagrant provision``` ~60 seconds

#### Any way to improve with a slow connection?
- Easiest way is cache or mirror the debian repository. This is also possible for git repository's.


### Warning
- Puppet Vscrepo is patched to allow depth with a branch option
- Puppet MySQL module is patched to allow Debian MariaDB
