class nginx {

	package { [ 'apache2-mpm-prefork', 'apache2-utils', 'apache2-bin', 'apache2.2-common']:
		ensure => purged,
		notify => Service['apache2'],
	}

	file { '/var/log/php':
		ensure => directory,
	}

	file { '/etc/php/7.0/fpm/pool.d/www.conf':
		ensure => absent,
		notify => Service['php7.0-fpm'],
	}

	file { '/etc/php/7.0/fpm/pool.d/vagrant.conf':
		content => template('nginx/php7-fpm.erb'),
		notify  => Service['php7.0-fpm'],
	}

	package { ['nginx-common', 'nginx-full', 'nginx' ]:
		ensure => latest,
		require => Service['apache2'],
	}

	file { '/etc/nginx/includes':
		ensure => directory,
		require => Package['nginx-common'],
	}

	file { '/etc/nginx/nginx.conf':
		content => template('nginx/nginx.conf.erb'),
		require => Package['nginx'],
		notify  => Service['nginx'],
	}

	file { '/etc/nginx/includes/typo3.conf':
		content => template('nginx/typo3.erb'),
		require => [File['/etc/nginx/includes'], Package['nginx']],
		notify  => Service['nginx'],
	}

	file { '/etc/nginx/includes/tools.conf':
		content => template('nginx/tools.erb'),
		require => [File['/etc/nginx/includes'], Package['nginx']],
		notify  => Service['nginx'],
	}

	file { '/etc/nginx/sites-available/default':
		content => template('nginx/site-default.erb'),
		require => Package['nginx'],
		notify  => Service['nginx'],
	}

	service { 'nginx':
		ensure  => running,
		require => Package['nginx'],
	}

	service { 'apache2':
		ensure => 'stopped',
	}

	file { "${document_root}/index.html":
		ensure  => absent,
		require => Package['nginx'],
	}

}
