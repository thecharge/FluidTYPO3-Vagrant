#!/bin/bash
WEB=$1
cd $WEB
if [ ! -f composer.lock ]; then
    if which composer >/dev/null; then
        echo 'TYPO3 will be installed via composer. Composer file is in www/composer.json (dev-master).'
        composer install
    else
     echo 'You need to install composer on your local system for a successful setup. https://getcomposer.org/'
     exit
    fi
fi
