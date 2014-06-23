class typo3 {

	define load_typo3 {
		vcsrepo { "${title}/typo3_src":
			ensure => latest,
			revision => $typo3_branch,
			provider => git,
			source => "https://github.com/TYPO3/TYPO3.CMS.git",
			depth => 1,
		}

		exec { 'typo3symlinks':
			cwd => $title,
			command => '/bin/ln -sf typo3_src/index.php && /bin/ln -sf typo3_src/typo3',
			require => Vcsrepo["${title}/typo3_src"],
			onlyif => ["/usr/bin/test ! -L ${title}/index.php","/usr/bin/test ! -L ${title}/typo3"],
		}

		file { [ "${title}/typo3conf", "${title}/typo3conf/ext" ]:
			ensure => directory
		}

		file { "${title}/typo3conf/ENABLE_INSTALL_TOOL":
			ensure => present,
			content => '',
			require => File["${title}/typo3conf"],
		}

		exec { 'chownweb':
			command => "/bin/chown -R vagrant:vagrant ${title}",
			require => [File["${title}/typo3conf/ENABLE_INSTALL_TOOL"], Exec['typo3symlinks'], File["${title}/typo3conf/ext"]],
		}

		mysql::db { 'typo3':
			user => 'typo3',
			password => 'devel',
			host => 'localhost',
			grant => ['all'],
			charset => 'utf8',
			require => File['/root/.my.cnf'],
		}

		exec { 'setupTYPO3':
			command => '/vagrant/scripts/installTYPO3.sh',
			require => [Exec['chownweb'],Mysql::Db['typo3']],
			onlyif => "/usr/bin/test ! -e ${title}/typo3conf/PackageStates.php",
		}
	}

	define load_extension {
		vcsrepo { "${document_root}/typo3conf/ext/${title}":
			ensure => latest,
			provider => git,
			source => "https://github.com/FluidTYPO3/${title}.git",
		}

		exec { "rsync${title}":
			command => "/usr/bin/rsync -r --update --delete ${document_root}/typo3conf/ext/${title} /vagrant/data/ext/",
			require => [Vcsrepo["${document_root}/typo3conf/ext/${title}"], Package['rsync']],
		}

		exec { "chown${title}":
			command => "/bin/chown -R vagrant:vagrant ${document_root}/typo3conf/ext/${title}",
			require => Vcsrepo["${document_root}/typo3conf/ext/${title}"],
		}

		exec { "loadTYPO3Extension${title}":
			cwd => $document_root,
			command => "${document_root}/typo3/cli_dispatch.phpsh extbase extension:install ${title}",
			require => Exec["chown${title}"],
			onlyif => "/usr/bin/test `/bin/grep '${title}..=' ${document_root}/typo3conf/PackageStates.php -A6 | /bin/grep -c =...active` -eq 0",
		}
	}

	vcsrepo { '/usr/share/php/PHP/CodeSniffer/Standards/FluidTYPO3':
		ensure => latest,
		revision => master,
		provider => git,
		source => 'https://github.com/FluidTYPO3/FluidTYPO3-CodingStandards.git',
		depth => 1,
		require => Exec['installPhpcs'],
	}

	load_typo3{ $document_root:
		require => [Package['curl'], Service['nginx'], Service['php5-fpm']]
	}

	exec { 'removeTYPO3Extensionscs':
		cwd => $document_root,
		command => "${document_root}/typo3/cli_dispatch.phpsh extbase extension:uninstall css_styled_content",
		require => Exec['setupTYPO3'],
		onlyif => "/usr/bin/test `/bin/grep 'css_styled_content..=' ${document_root}/typo3conf/PackageStates.php -A6 | /bin/grep -c =...inactive` -eq 0",
	}

	exec { 'loadTYPO3Extensionscheduler':
		cwd => $document_root,
		command => "${document_root}/typo3/cli_dispatch.phpsh extbase extension:install scheduler",
		require => Exec['setupTYPO3'],
		onlyif => "/usr/bin/test `/bin/grep 'scheduler..=' ${document_root}/typo3conf/PackageStates.php -A6 | /bin/grep -c =...active` -eq 0",
	}

	cron { scheduler:
		command => "${document_root}/typo3/cli_dispatch.phpsh scheduler",
		user => vagrant,
		minute => '*',
		require => Exec["loadTYPO3Extensionscheduler"],
	}

	load_extension { 'vhs':
		require => Exec['setupTYPO3'],
	}

	load_extension { 'flux':
		require => Load_extension['vhs'],
	}

	load_extension { ['builder', 'fluidcontent', 'fluidcontent_core', 'fluidpages', 'fluidtypo3', 'schemaker', 'view']:
		require => Load_extension['flux'],
	}

}
