class network {
	package { ['cachefilesd']:
		ensure => present,
	}

	host { $fqdn:
		ensure => present,
		ip     => '127.0.0.1',
	}

	exec { 'hostname':
		command => "/usr/bin/hostnamectl set-hostname ${fqdn}",
	}

	file { '/etc/default/cachefilesd':
		ensure  => present,
		content => 'RUN=yes',
		require => Package['cachefilesd'],
	}

}
