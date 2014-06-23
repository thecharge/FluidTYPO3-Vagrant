class defaultpackage {
	package { ['htop', 'iftop', 'pwgen', 'mytop', 'git', 'wget', 'curl', 'multitail', 'iotop', 'augeas-tools', 'libaugeas-ruby', 'linux-headers-amd64', 'rsync']:
		ensure => present
	}
}
