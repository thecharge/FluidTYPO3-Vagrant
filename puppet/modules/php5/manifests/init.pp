class php5 {
	package { ['php5-cli', 'php5-fpm', 'php5-mysqlnd', 'php5-gd', 'php5-intl', 'php5-mcrypt', 'php-pear', 'php5-imap', 'php-auth', 'mcrypt', 'imagemagick', 'php5-curl', 'php5-tidy', 'php5-xmlrpc', 'php5-xsl', 'php-soap', 'php-mail', 'php5-dev', 'php5-common']:
		ensure => present,
	}

	service { 'php5-fpm':
		ensure  => running,
		require => Package['php5-fpm'],
	}

	define php::augeas (
		$entry,
		$ensure = present,
		$target = '/etc/php5/fpm/php.ini',
		$value = '',
	) {
		$changes = $ensure ? {
			present => ["set '${entry}' '${value}'"],
			absent => ["rm '${entry}'"],
		}
		augeas { "php_ini-${name}":
			incl    => $target,
			lens    => 'Php.lns',
			changes => $changes,
			notify  => Service['php5-fpm'],
			require => [Package['augeas-tools'], Package['php5-fpm']],
		}
	}

	php::augeas {
		'php-memorylimit':
			entry => 'PHP/memory_limit',
			value => '256M';
		'php-upload_max_filesize':
			entry => 'PHP/upload_max_filesize',
			value => '256M';
		'php-post_max_size':
			entry => 'PHP/post_max_size',
			value => '256M';
		'php-expose_php':
			entry => 'PHP/expose_php',
			value => 'off';
		'php-display_errors':
			entry => 'PHP/display_errors',
			value => 'On';
		'php-max_execution_time':
			entry => 'PHP/max_execution_time',
			value => '240';
		'php-open_basedir':
			entry => 'PHP/open_basedir',
			value => "${document_root}:/usr/share/php5:/usr/share/php:/tmp";
		'php-upload_tmp_dir':
			entry => 'PHP/upload_tmp_dir',
			value => '/tmp';
		'php-session_save_path':
			entry => 'Session/session.save_path',
			value => '/tmp';
		'php-date_timezone':
			entry => 'Date/date.timezone',
			value => 'Europe/Berlin';
		'php-cgi_fix_pathinfo':
			entry => 'PHP/cgi.fix_pathinfo',
			value => '0';
		'xdebug-zend_extension':
			entry  => 'xdebug/zend_extension',
			value  => 'xdebug.so',
			target => '/etc/php5/mods-available/xdebug.ini';
		'xdebug-xdebug_max_nesting_level':
			entry  => 'xdebug/xdebug.max_nesting_level',
			value  => '1000',
			target => '/etc/php5/mods-available/xdebug.ini';
		'xdebug-xdebug_remote_enable':
			entry  => 'xdebug/xdebug.remote_enable',
			value  => 'on',
			target => '/etc/php5/mods-available/xdebug.ini';
		'xdebug-xdebug_remote_connect_back':
			entry  => 'xdebug/xdebug.remote_connect_back',
			value  => 'on',
			target => '/etc/php5/mods-available/xdebug.ini';
		'xdebug-xdebug_idekey':
			entry  => 'xdebug/xdebug.idekey',
			value  => 'vagrant',
			target => '/etc/php5/mods-available/xdebug.ini';
		'xdebug-xdebug_profiler_enable_trigger':
			entry  => 'xdebug/xdebug.profiler_enable_trigger',
			value  => '1',
			target => '/etc/php5/mods-available/xdebug.ini';
	}

	exec { 'installPhpcs':
		command => '/usr/bin/pear install PHP_CodeSniffer',
		unless  => '/usr/bin/test -f /usr/bin/phpcs',
		require => Package['php-pear'],
	}

	exec { 'installPhpXdebug':
		command => '/usr/bin/pecl install xdebug',
		unless  => '/usr/bin/test -f /usr/lib/php5/*/xdebug.so',
		require => [Package['php-pear'], Package['php5-dev']],
	}

	exec { 'enablePhpXdebug':
		command => '/usr/sbin/php5enmod xdebug',
		unless  => '/usr/bin/test -f /etc/php5/fpm/conf.d/20-xdebug.ini',
		require => [Exec['installPhpXdebug'], Php::Augeas['xdebug-zend_extension']],
		notify  => Service['php5-fpm'],
	}

	exec { 'installPhpUnit':
		cwd     => '/usr/local/bin',
		command => '/usr/bin/wget https://phar.phpunit.de/phpunit.phar -O phpunit && /bin/chmod +x phpunit',
		unless  => '/usr/bin/test -f /usr/local/bin/phpunit',
	}

	exec { 'installComposer':
		cwd     => '/usr/local/bin',
		command => '/usr/bin/wget https://getcomposer.org/composer.phar -O composer && /bin/chmod +x composer',
		unless  => '/usr/bin/test -f /usr/local/bin/composer',
	}

}
