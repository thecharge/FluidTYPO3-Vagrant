class { '::mysql::server':
	root_password => 'password'
}

include apt
include defaultpackage
include network
include shell
include ssl
include php5
include nginx
include mail
include tools
include typo3
