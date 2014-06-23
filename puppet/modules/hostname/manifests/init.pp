class hostname {

	host { $fqdn:
		ensure => present,
		ip => '127.0.0.1',
	}

	file { '/etc/hostname':
		content => "${fqdn}",
		notify => Service['hostname.sh'],
	}

	service { 'hostname.sh':
		ensure => running,
	}

	exec { 'dhclient':
		command => '/sbin/dhclient eth0 && /sbin/dhclient eth1',
		subscribe => Service['hostname.sh'],
		refreshonly => true,
	}

}
