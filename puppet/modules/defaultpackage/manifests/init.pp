class defaultpackage {
	package { ['htop', 'iftop', 'graphviz', 'pwgen', 'mytop', 'wget', 'curl', 'multitail', 'iotop', 'augeas-tools', 'libaugeas-ruby', 'linux-headers-amd64', 'rsync']:
		ensure => present,
	}

	exec { 'git-backports':
		command => '/usr/bin/apt-get -t wheezy-backports -y -q install git',
		onlyif  => '/usr/bin/test `/usr/bin/dpkg -l git | /bin/grep -c ~bpo` -eq 0',
	}

	Exec['apt-update'] -> Exec['git-backports'] -> Vcsrepo <| |>

}
