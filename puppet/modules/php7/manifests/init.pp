class php7 {
	package { [ 'php7.0-common', 'php7.0-cli', 'php7.0-fpm', 'php7.0-mysql', 'php7.0-gd', 'php7.0-intl',  'php7.0-imap', 'mcrypt', 'imagemagick', 'php7.0-curl', 'php7.0-tidy', 'php7.0-dev' , 'php7.0-opcache' ]:
		ensure => present,
	}

	service { 'php7.0-fpm':
		ensure  => running,
		require => Package['php7.0-fpm'],
	}

	define php::augeas (
		$entry,
		$ensure = present,
		$target = '/etc/php/7.0/fpm/php.ini',
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
			notify  => Service['php7.0-fpm'],
			require => [Package['augeas-tools'], Package['php7.0-fpm']],
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
		'php-max_input_vars':
			entry => 'PHP/max_input_vars',
			value => '1500';
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
			value => "${document_root}:/usr/share/php7.0:/usr/share/php:/tmp:/usr/bin:/dev/urandom:/usr/local/bin";
		'php-upload_tmp_dir':
			entry => 'PHP/upload_tmp_dir',
			value => '/tmp';
		'php-session_save_path':
			entry => 'Session/session.save_path',
			value => '/tmp';
		'php-date_timezone':
			entry => 'Date/date.timezone',
			value => 'Europe/Berlin';
		'php-date_timezone-cli':
			entry => 'Date/date.timezone',
			value => 'Europe/Berlin',
			target => '/etc/php/7.0/cli/php.ini';
		'php-cgi_fix_pathinfo':
			entry => 'PHP/cgi.fix_pathinfo',
			value => '0';
		'xdebug-zend_extension':
			entry  => 'xdebug/zend_extension',
			value  => 'xdebug.so',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_max_nesting_level':
			entry  => 'xdebug/xdebug.max_nesting_level',
			value  => '1000',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_remote_enable':
			entry  => 'xdebug/xdebug.remote_enable',
			value  => 'on',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_remote_connect_back':
			entry  => 'xdebug/xdebug.remote_connect_back',
			value  => 'on',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_idekey':
			entry  => 'xdebug/xdebug.idekey',
			value  => 'vagrant',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
		'xdebug-xdebug_profiler_enable_trigger':
			entry  => 'xdebug/xdebug.profiler_enable_trigger',
			value  => '1',
			target => '/etc/php/7.0/mods-available/xdebug.ini';
	}

#	exec { 'installPhpcs':
#		command => '/usr/bin/pear install PHP_CodeSniffer',
#		unless  => '/usr/bin/test -f /usr/bin/phpcs',
#		require => Package['php-pear'],
#	}
#
#	exec { 'installPhpXdebug':
#		command => '/usr/bin/pecl install xdebug',
#		unless  => '/usr/bin/test -f /usr/lib/php7.0/*/xdebug.so',
#		require => [Package['php-pear'], Package['php7.0-dev']],
#	}
#
#	exec { 'enablePhpXdebug':
#		command => '/usr/sbin/php7.0enmod xdebug',
#		unless  => '/usr/bin/test -f /etc/php/7.0/fpm/conf.d/20-xdebug.ini',
#		require => [Exec['installPhpXdebug'], Php::Augeas['xdebug-zend_extension']],
#		notify  => Service['php7.0-fpm'],
#	}

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
