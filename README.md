# FluidTYPO3 Vagrant

## What it does?
Create a Debian based Virtualbox VM and install TYPO3 and a few helper tools.

## Warning
This setup is only for local test setup. TrustedHostPattern is a wildcard.
Also this project is in a early state and you need to fill a issue report.

## Quick-start
1. Checkout the repo, edit Vagrantfile facters.
2. Take a look in Configuration.yaml
3. ```vagrant up```
4. Domain is http://dev.fluidtypo3.org
5. Have fun :)

### Features
- Nginx 1.6.x with php-fpm
- MariaDB 10.1
- Postfix + Dovecot (IMAP for mail-tests)
- zsh with grml
- github sources (TYPO3, Webgrind, Rouncubemail, phpMyAdmin, OpCacheGUI, FluidTYPO3)
- webgrind - Xdebug profiler gui http://dev.fluidtypo3.org/webgrind
- phpMyAdmin - http://dev.fluidtypo3.org/phpMyAdmin
+ Opcache Stats (3 different tools)
    * Opcache http://dev.fluidtypo3.org/opcache-dashboard.php
    * OpCacheGUI http://dev.fluidtypo3.org/OpCacheGUI
+ roundcubemail http://dev.fluidtypo3.org/webmail - All mails are send to development@localhost
    * Login via development Password password
- Cronjob for scheduler
- Codesniffer with FluidTYPO3 standard
- PHPunit for testing
- Composer

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

### Xdebug
Use a Firefox or Chrome extension to active debug or profiler

- [Firefox Addon - The easiest Xdebug](https://addons.mozilla.org/de/firefox/addon/the-easiest-xdebug)
- [Chrome Addon - Xdebug helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc)

#### phpStorm/IDEA remote listener
Activate in PhpStorm/IDEA ´´´Start Listening for PHP Debug Connections´´´ and turn the debug option in browser addon on. Define a breakpoint and reload the page.

#### Webgrind profiler
Activate the profiler function of the addon. Instead of a browser-extension ?XDEBUG_PROFILE as GET parameter is also possible.

### FAQ

#### Do we support Windows as host?
- We only support the slow Virtualbox shared folder or NFS under Windows with winnfsd plugin. For SMB take a look in [Manual](https://docs.vagrantup.com/v2/synced-folders/index.html). We can"t test under windows and feedback is welcome.

#### Initial download volume?
- First time 420 MB for cache vagrant box and 150 MB each complete vagrant up

#### Build time
- Depends on a lot of factors. HDD speed, connection speed<br />
```vagrant up``` ~7min 30sec (install/start VM + first provision 360 sec)<br />
```vagrant provision``` ~60 seconds

#### Encrypted disk
- NFS does not support encrypted host storage as mount.

### Warning
- Puppet Vscrepo is patched to allow depth with a branch option
- Puppet MySQL module is patched to allow Debian MariaDB
