class network {
	package { ['cachefilesd']:
		ensure => present,
	}

	host { $fqdn:
		ensure => present,
		ip     => '127.0.0.1',
	}

	file { '/etc/hostname':
		content => "${fqdn}",
		notify  => Service['hostname.sh'],
	}

	service { 'hostname.sh':
		ensure => running,
	}

	file { '/etc/default/cachefilesd':
		ensure  => present,
		content => 'RUN=yes',
		require => Package['cachefilesd'],
	}

}
