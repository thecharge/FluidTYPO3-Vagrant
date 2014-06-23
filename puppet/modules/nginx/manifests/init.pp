class nginx {

	package { [ 'apache2-mpm-prefork', 'apache2-utils', 'apache2.2-bin', 'apache2.2-common', 'libapache2-mod-php5' ]:
		ensure => purged,
	}

	file { '/var/log/php-fpm':
		ensure => directory,
	}

	file { '/etc/php5/fpm/pool.d/www.conf':
		ensure => absent,
		notify => Service['php5-fpm'],
	}

	file { '/etc/php5/fpm/pool.d/vagrant.conf':
		content => template('nginx/php5-fpm.erb'),
		notify => Service['php5-fpm'],
	}

	package { [ 'nginx', 'nginx-full', 'nginx-common']:
		ensure => latest,
	}

	file { '/etc/nginx/includes':
		ensure => directory,
	}

	file { '/etc/nginx/includes/typo3.conf':
		content => template('nginx/typo3.erb'),
		require => [File['/etc/nginx/includes'], Package['nginx']],
		notify => Service['nginx'],
	}

	file { '/etc/nginx/includes/tools.conf':
		content => template('nginx/tools.erb'),
		require => [File['/etc/nginx/includes'], Package['nginx']],
		notify => Service['nginx'],
	}

	file { '/etc/nginx/sites-available/default':
		content => template('nginx/nginx.erb'),
		require => Package['nginx'],
		notify => Service['nginx'],
	}

	service { 'nginx':
		ensure => running,
		require => Package['nginx'],
	}

	file { "${document_root}/index.html":
		ensure => absent,
		require => Package['nginx'],
	}

}
