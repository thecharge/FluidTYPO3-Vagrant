class defaultpackage {
	package { ['htop', 'iftop', 'graphviz', 'pwgen', 'mytop', 'wget', 'curl', 'multitail', 'iotop', 'augeas-tools', 'libaugeas-ruby', 'linux-headers-amd64', 'rsync']:
		ensure => present,
	}

	exec { 'git-backports':
		command => '/usr/bin/apt-get -t wheezy-backports -y -q install git',
	}

	Exec['apt-update'] -> Exec['git-backports'] -> Vcsrepo <| |>

}
