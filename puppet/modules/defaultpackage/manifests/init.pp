class defaultpackage {
	package { ['htop', 'git', 'iftop', 'graphviz', 'pwgen', 'mytop', 'wget', 'curl', 'multitail', 'iotop', 'augeas-tools', 'libaugeas-ruby', 'rsync']:
		ensure => present,
	}
}
