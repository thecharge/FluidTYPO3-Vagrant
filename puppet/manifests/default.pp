class { '::mysql::server':
	root_password => 'password',
	override_options => {
		mysqld => { bind-address => '0.0.0.0'}
	},
	restart => true,
}

include apt
include defaultpackage
include network
include shell
include ssl
include nginx
include php7
include mail
include tools
include typo3
