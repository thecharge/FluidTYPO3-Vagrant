class typo3 {

	define load_typo3 {
		vcsrepo { "${title}/typo3_src":
			ensure   => latest,
			revision => $typo3_branch,
			provider => git,
			source   => "https://github.com/TYPO3/TYPO3.CMS.git",
			depth    => 1,
		}

		exec { 'typo3symlinks':
			cwd     => $title,
			command => '/bin/ln -sf typo3_src/index.php && /bin/ln -sf typo3_src/typo3',
			require => Vcsrepo["${title}/typo3_src"],
			onlyif  => ["/usr/bin/test ! -L ${title}/index.php","/usr/bin/test ! -L ${title}/typo3"],
		}

		file { [ "${title}/typo3conf", "${title}/typo3conf/ext" ]:
			ensure => directory
		}

		file { "${title}/typo3conf/ENABLE_INSTALL_TOOL":
			ensure  => present,
			content => '',
			require => File["${title}/typo3conf"],
		}

		mysql::db { 'typo3':
			user     => 'typo3',
			password => 'password',
			host     => 'localhost',
			grant    => ['all'],
			charset  => 'utf8',
			require  => File['/root/.my.cnf'],
		}

		exec { 'setupTYPO3':
			command => "/vagrant/installTYPO3.sh ${document_root}",
			require => [Mysql::Db['typo3']],
			onlyif  => "/usr/bin/test ! -e ${title}/typo3conf/PackageStates.php",
		}
	}

	define load_extension {
		vcsrepo { "${document_root}/typo3conf/ext/${title}":
			ensure   => latest,
			provider => git,
			revision => $fluidtypo3_branch,
			source   => "https://github.com/FluidTYPO3/${title}.git",
		}

		exec { "loadTYPO3Extension${title}":
			cwd     => $document_root,
			command => "${document_root}/typo3/cli_dispatch.phpsh extbase extension:install ${title}",
			require => Vcsrepo["${document_root}/typo3conf/ext/${title}"],
			onlyif  => "/usr/bin/test `/bin/grep '${title}..=' ${document_root}/typo3conf/PackageStates.php -A6 | /bin/grep -c =...active` -eq 0",
		}
	}

	file { ["${document_root}/typo3temp"]:
		ensure => directory
	}

	mount { "${document_root}/typo3temp":
		device => 'tmpfs',
		atboot => true,
		options => 'size=256M,rw',
		ensure => mounted,
		fstype => 'tmpfs',
		require => [File["${document_root}/typo3temp"]],
		remounts => false,
	}

	cron { mount:
		command => "mount -a",
		user    => root,
		minute  => '*',
	}

	vcsrepo { '/usr/share/php/PHP/CodeSniffer/Standards/FluidTYPO3':
		ensure   => latest,
		revision => master,
		provider => git,
		source   => 'https://github.com/FluidTYPO3/FluidTYPO3-CodingStandards.git',
		require  => Exec['installPhpcs'],
	}

	load_typo3 { $document_root:
		require => [Package['curl'], Service['nginx'], Service['php5-fpm'], Mount["${document_root}/typo3temp"]]
	}

	exec { 'removeTYPO3ExtensionCsc':
		cwd     => $document_root,
		command => "${document_root}/typo3/cli_dispatch.phpsh extbase extension:uninstall css_styled_content",
		require => Exec['setupTYPO3'],
		onlyif  => "/usr/bin/test `/bin/grep 'css_styled_content..=' ${document_root}/typo3conf/PackageStates.php -A6 | /bin/grep -c =...inactive` -eq 0",
	}

	exec { 'loadTYPO3Extensionscheduler':
		cwd     => $document_root,
		command => "${document_root}/typo3/cli_dispatch.phpsh extbase extension:install scheduler",
		require => Exec['setupTYPO3'],
		onlyif  => "/usr/bin/test `/bin/grep 'scheduler..=' ${document_root}/typo3conf/PackageStates.php -A6 | /bin/grep -c =...active` -eq 0",
	}

	cron { scheduler:
		command => "${document_root}/typo3/cli_dispatch.phpsh scheduler",
		user    => vagrant,
		minute  => '*',
		require => Exec["loadTYPO3Extensionscheduler"],
	}

	load_extension { 'vhs':
		require => Exec['setupTYPO3'],
	}

	load_extension { 'flux':
		require => Load_extension['vhs'],
	}

	load_extension { ['builder', 'fluidcontent', 'fluidcontent_core', 'fluidpages']:
		require => Load_extension['flux'],
	}

	file { "${document_root}/typo3conf/AdditionalConfiguration.php":
		ensure  => present,
		source  => "${document_root}/typo3conf/ext/fluidcontent_core/Build/AdditionalConfiguration.php",
		require => Load_extension['fluidcontent_core'],
	}

	exec { 'addSite':
		command => "/usr/bin/mysql --user='typo3' --password='password' --database='typo3' --execute=\"INSERT INTO pages (uid, pid, t3ver_oid, t3ver_id, t3ver_wsid, t3ver_label, t3ver_state, t3ver_stage, t3ver_count, t3ver_tstamp, t3ver_move_id, t3_origuid, tstamp, sorting, deleted, perms_userid, perms_groupid, perms_user, perms_group, perms_everybody, editlock, crdate, cruser_id, hidden, title, doktype, TSconfig, storage_pid, is_siteroot, php_tree_stop, tx_impexp_origuid, url, starttime, endtime, urltype, shortcut, shortcut_mode, no_cache, fe_group, subtitle, layout, url_scheme, target, media, lastUpdated, keywords, cache_timeout, cache_tags, newUntil, description, no_search, SYS_LASTCHANGED, abstract, module, extendToSubpages, author, author_email, nav_title, nav_hide, content_from_pid, mount_pid, mount_pid_ol, alias, l18n_cfg, fe_login_mode, backend_layout, backend_layout_next_level, categories, tx_fluidpages_templatefile, tx_fluidpages_layout, tx_fed_page_flexform, tx_fed_page_flexform_sub, tx_fed_page_controller_action, tx_fed_page_controller_action_sub) VALUES
 (1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, UNIX_TIMESTAMP(), 128, 0, 1, 0, 31, 27, 0, 0, UNIX_TIMESTAMP(), 1, 0, 'Homepage', 1, '', 0, 1, 0, 0, '', 0, 0, 1, 0, 0, 0, '', '', 0, 0, '', '0', 0, '', 0, '', 0, '', 0, 0, '', '', 0, '', '', '', 0, 0, 0, 0, '', 0, 0, 'fluidpages__fluidpages', 'fluidpages__fluidpages', 0, NULL, NULL, NULL, NULL, '', '');\"" ,
		require => Load_extension['fluidpages'],
		onlyif  => '/usr/bin/test `/usr/bin/mysql -s -N --user="typo3" --password="password" --database="typo3" --execute="SELECT count(*) FROM pages WHERE uid=1"` -eq 0',
	}

	exec { 'addSiteTemplate':
		command => "/usr/bin/mysql --user='typo3' --password='password' --database='typo3' --execute=\"INSERT INTO sys_template (uid, pid, t3ver_oid, t3ver_id, t3ver_wsid, t3ver_label, t3ver_state, t3ver_stage, t3ver_count, t3ver_tstamp, t3_origuid, tstamp, sorting, crdate, cruser_id, title, sitetitle, hidden, starttime, endtime, root, clear, include_static_file, constants, config, nextLevel, description, basedOn, deleted, includeStaticAfterBasedOn, static_file_mode, tx_impexp_origuid) VALUES
 (1, 1, 0, 0, 0, '', 0, 0, 0, 0, 0, 1414543149, 256, 1414543099, 1, 'Maintemplate', '', 0, 0, 0, 1, 3, 'EXT:fluidcontent_core/Configuration/TypoScript', NULL, '', '', NULL, '', 0, 0, 0, 0);\"" ,
		require => Load_extension['fluidpages'],
		onlyif  => '/usr/bin/test `/usr/bin/mysql -s -N --user="typo3" --password="password" --database="typo3" --execute="SELECT count(*) FROM sys_template WHERE uid=1"` -eq 0',
	}

	exec { 'addExtensionlistTask':
		command => "/usr/bin/mysql --user='typo3' --password='password' --database='typo3' --execute=\"INSERT INTO tx_scheduler_task (uid, crdate, disable, description, nextexecution, lastexecution_time, lastexecution_failure, lastexecution_context, serialized_task_object, serialized_executions, task_group) VALUES
 (1, 0, 0, '', 1, 0, '', '', 0x4f3a35353a225459504f335c434d535c457874656e73696f6e6d616e616765725c5461736b5c557064617465457874656e73696f6e4c6973745461736b223a363a7b733a31303a22002a007461736b556964223b693a313b733a31313a22002a0064697361626c6564223b623a303b733a31323a22002a00657865637574696f6e223b4f3a32393a225459504f335c434d535c5363686564756c65725c457865637574696f6e223a363a7b733a383a22002a007374617274223b693a313431343838363430303b733a363a22002a00656e64223b733a303a22223b733a31313a22002a00696e74657276616c223b693a38363430303b733a31313a22002a006d756c7469706c65223b733a313a2230223b733a31303a22002a0063726f6e436d64223b733a303a22223b733a32333a22002a0069734e657753696e676c65457865637574696f6e223b623a303b7d733a31363a22002a00657865637574696f6e54696d65223b693a313431343937323830303b733a31343a22002a006465736372697074696f6e223b733a303a22223b733a31323a22002a007461736b47726f7570223b693a303b7d, NULL, 0);\"",
		require => Exec['loadTYPO3Extensionscheduler'],
		onlyif  => '/usr/bin/test `/usr/bin/mysql -s -N --user="typo3" --password="password" --database="typo3" --execute="SELECT count(*) FROM tx_scheduler_task WHERE uid=1"` -eq 0',
	}

}
