#!/bin/bash

HOST=http://localhost/
DOCUMENT_ROOT=$1
DATABASE_USER=typo3
DATABASE_PASSWORD=password
DATABASE=typo3
SITENAME=FluidTYPO3
ADMIN_USER=admin
ADMIN_PASSWORD=password
TRUSTED_HOSTS_PATTERN=.*

setHash () {
	HASH=$(curl -skL "${HOST}typo3/sysext/install/Start/Install.php" 2>&1 | grep 'token' | grep -m 1 -Po '(?<=value=").*(?=")')
}

curl "${HOST}typo3/sysext/install/Start/Install.php" -H 'Content-Type: application/x-www-form-urlencoded' --data "install%5Baction%5D=environmentAndFolders&install%5Bset%5D=execute"

setHash

curl "${HOST}typo3/sysext/install/Start/Install.php?install\[redirectCount\]=0&install\[context\]=standalone&install\[controller\]=step&install\[action\]=databaseConnect" -H 'Content-Type: application/x-www-form-urlencoded' --data "install%5Bcontroller%5D=step&install%5Baction%5D=databaseConnect&install%5Btoken%5D=${HASH}&install%5Bcontext%5D=standalone&install%5Bset%5D=execute&install%5Bvalues%5D%5Busername%5D=${DATABASE_USER}&install%5Bvalues%5D%5Bpassword%5D=${DATABASE_PASSWORD}&install%5Bvalues%5D%5Bhost%5D=localhost&install%5Bvalues%5D%5Bport%5D=3306&install%5Bvalues%5D%5Bsocket%5D="

setHash

curl "${HOST}typo3/sysext/install/Start/Install.php?install\[redirectCount\]=2&install\[context\]=standalone&install\[controller\]=step&install\[action\]=databaseSelect" -H 'Content-Type: application/x-www-form-urlencoded' --data "install%5Bcontroller%5D=step&install%5Baction%5D=databaseSelect&install%5Btoken%5D=${HASH}&install%5Bcontext%5D=standalone&install%5Bset%5D=execute&install%5Bvalues%5D%5Btype%5D=existing&install%5Bvalues%5D%5Bexisting%5D=${DATABASE}&install%5Bvalues%5D%5Bnew%5D="

setHash

curl "${HOST}typo3/sysext/install/Start/Install.php?install\[redirectCount\]=3&install\[context\]=standalone&install\[controller\]=step&install\[action\]=databaseData" -H 'Content-Type: application/x-www-form-urlencoded' --data "install%5Bcontroller%5D=step&install%5Baction%5D=databaseData&install%5Btoken%5D=${HASH}&install%5Bcontext%5D=standalone&install%5Bset%5D=execute&install%5Bvalues%5D%5Busername%5D=$ADMIN_USER&install%5Bvalues%5D%5Bpassword%5D=${ADMIN_PASSWORD}&install%5Bvalues%5D%5Bsitename%5D=${SITENAME}"

grep trustedHostsPattern ${DOCUMENT_ROOT}/typo3conf/LocalConfiguration.php || {
	sed -i "/'SYS' =/a \\\t\t'trustedHostsPattern' => '${TRUSTED_HOSTS_PATTERN}'," ${DOCUMENT_ROOT}/typo3conf/LocalConfiguration.php
}

mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="SELECT username FROM be_users WHERE username='_cli_lowlevel'" | grep -q '_cli_lowlevel' || {
	mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="INSERT INTO be_users (username) VALUES ('_cli_lowlevel')"
}

mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="SELECT username FROM be_users WHERE username='_cli_scheduler'" | grep -q '_cli_scheduler' || {
	mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="INSERT INTO be_users (username) VALUES ('_cli_scheduler')"
}

setHash

curl "${HOST}typo3/sysext/install/Start/Install.php?install\[redirectCount\]=4&install\[context\]=standalone&install\[controller\]=step&install\[action\]=defaultConfiguration" -H 'Content-Type: application/x-www-form-urlencoded' --data "install%5Bcontroller%5D=step&install%5Baction%5D=defaultConfiguration&install%5Btoken%5D=${HASH}&install%5Bcontext%5D=standalone&install%5Bset%5D=execute&install%5Bvalues%5D%5Bloaddistributions%5D=1"
