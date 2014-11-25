class tools {

	vcsrepo { '/usr/share/php/phpMyAdmin':
		ensure   => latest,
		revision => 'STABLE',
		provider => git,
		source   => 'https://github.com/phpmyadmin/phpmyadmin.git',
		depth    => '1',
		require  => Package['php5-common'],
	}

	exec { 'opcache-dashboard':
		cwd     => '/usr/share/php',
		command => '/usr/bin/wget https://raw.githubusercontent.com/carlosbuenosvinos/opcache-dashboard/master/opcache.php -O opcache-dashboard.php',
		unless  => '/usr/bin/test -f /usr/share/php/opcache-dashboard.php',
		require => Package['php5-common'],
	}

	vcsrepo { '/usr/share/php/OpCacheGUI':
		ensure   => latest,
		revision => 'master',
		provider => git,
		source   => 'https://github.com/PeeHaa/OpCacheGUI.git',
		depth    => '1',
		require  => Package['php5-common'],
	}

	vcsrepo { '/usr/share/php/webgrind':
		ensure   => latest,
		revision => 'master',
		provider => git,
		source   => 'https://github.com/jokkedk/webgrind.git',
		depth    => '1',
		require  => Package['php5-common'],
	}

	file { '/usr/local/bin/dot':
		ensure => 'link',
		target => '/usr/bin/dot',
		require => Package['graphviz'],
	}

	vcsrepo { '/usr/share/php/roundcubemail':
		ensure   => latest,
		revision => 'master',
		provider => git,
		source   => 'https://github.com/roundcube/roundcubemail.git',
		depth    => '1',
		require  => Package['php5-common'],
	}

	mysql::db { 'roundcube':
		user     => 'roundcube',
		password => 'password',
		host     => 'localhost',
		grant    => ['all'],
		charset  => 'utf8',
		require  => File['/root/.my.cnf'],
	}

	exec { 'roundcube-sql-import':
		command => '/usr/bin/mysql -u roundcube -ppassword roundcube < /usr/share/php/roundcubemail/SQL/mysql.initial.sql',
		require => [Vcsrepo['/usr/share/php/roundcubemail'], Mysql::Db['roundcube']],
		onlyif  => '/usr/bin/test ! -e /usr/share/php/roundcubemail/config/config.inc.php',
	}

	file { '/usr/share/php/roundcubemail/config/config.inc.php':
		content => template('tools/roundcubemail.config.erb'),
		require => Exec['roundcube-sql-import'],
	}

	file { ['/usr/share/php/roundcubemail/temp', '/usr/share/php/roundcubemail/logs']:
		mode    => '0777',
		require => Vcsrepo['/usr/share/php/roundcubemail'],
	}

}
