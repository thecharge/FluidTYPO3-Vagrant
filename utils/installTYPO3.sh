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

mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="SELECT uid FROM pages WHERE uid=1" | grep -q '1' || {
	mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="INSERT INTO pages (uid, pid, t3ver_oid, t3ver_id, t3ver_wsid, t3ver_label, t3ver_state, t3ver_stage, t3ver_count, t3ver_tstamp, t3ver_move_id, t3_origuid, tstamp, sorting, deleted, perms_userid, perms_groupid, perms_user, perms_group, perms_everybody, editlock, crdate, cruser_id, hidden, title, doktype, TSconfig, storage_pid, is_siteroot, php_tree_stop, tx_impexp_origuid, url, starttime, endtime, urltype, shortcut, shortcut_mode, no_cache, fe_group, subtitle, layout, url_scheme, target, media, lastUpdated, keywords, cache_timeout, cache_tags, newUntil, description, no_search, SYS_LASTCHANGED, abstract, module, extendToSubpages, author, author_email, nav_title, nav_hide, content_from_pid, mount_pid, mount_pid_ol, alias, l18n_cfg, fe_login_mode, backend_layout, backend_layout_next_level, categories, tx_fluidpages_templatefile, tx_fluidpages_layout, tx_fed_page_flexform, tx_fed_page_flexform_sub, tx_fed_page_controller_action, tx_fed_page_controller_action_sub) VALUES
 (1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, UNIX_TIMESTAMP(), 128, 0, 1, 0, 31, 27, 0, 0, UNIX_TIMESTAMP(), 1, 0, 'Homepage', 1, '', 0, 1, 0, 0, '', 0, 0, 1, 0, 0, 0, '', '', 0, 0, '', '0', 0, '', 0, '', 0, '', 0, 0, '', '', 0, '', '', '', 0, 0, 0, 0, '', 0, 0, 'fluidpages__fluidpages', 'fluidpages__fluidpages', 0, NULL, NULL, NULL, NULL, '', '');"
}

mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="SELECT uid FROM sys_template WHERE uid=1" | grep -q '1' || {
	mysql --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE" --execute="INSERT INTO sys_template (uid, pid, t3ver_oid, t3ver_id, t3ver_wsid, t3ver_label, t3ver_state, t3ver_stage, t3ver_count, t3ver_tstamp, t3_origuid, tstamp, sorting, crdate, cruser_id, title, sitetitle, hidden, starttime, endtime, root, clear, include_static_file, constants, config, nextLevel, description, basedOn, deleted, includeStaticAfterBasedOn, static_file_mode, tx_impexp_origuid) VALUES
 (1, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 1414543149, 256, 1414543099, 1, 'Maintemplate', '', 0, 0, 0, 1, 3, 'EXT:fluidcontent_core/Configuration/TypoScript', NULL, '', '', NULL, '', 0, 0, 0, 0)"
}

setHash

curl "${HOST}typo3/sysext/install/Start/Install.php?install\[redirectCount\]=4&install\[context\]=standalone&install\[controller\]=step&install\[action\]=defaultConfiguration" -H 'Content-Type: application/x-www-form-urlencoded' --data "install%5Bcontroller%5D=step&install%5Baction%5D=defaultConfiguration&install%5Btoken%5D=${HASH}&install%5Bcontext%5D=standalone&install%5Bset%5D=execute&install%5Bvalues%5D%5Bloaddistributions%5D=1"
