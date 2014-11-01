# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'
DOCUMENT_ROOT = '/var/www'

Vagrant.require_version ">= 1.6.2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = 'puphpet/debian75-x64'

	# Activate if your box need to be available in local network
	#config.vm.network 'public_network'

	# Change ip: '172.23.23.23' to run more than one VM or replace it with type: 'dhcp' if you need
	config.vm.network 'private_network', ip: '172.23.23.23'

	# If true, then any SSH connections made will enable agent forwarding.
	# Default value: false
	config.ssh.forward_agent = true

	#Disable default mount
	config.vm.synced_folder '.', '/vagrant', :disabled => true
	config.vm.synced_folder 'utils', '/vagrant'

	# Share an additional folder to the guest VM.
	# Sync local folders in VM and ignore git folders.

	config.vm.synced_folder 'data', DOCUMENT_ROOT, id: 'fluidTYPO3', type: 'nfs',
			mount_options: ['rw', 'vers=3', 'tcp']
			# Comment in and run vagrant reload and NFS has a cache server.
			#mount_options: ['rw', 'vers=3', 'tcp', 'fsc']

	config.vm.provider 'virtualbox' do |vb|
		# Disable headless mode
		# vb.gui = true

		# Use VBoxManage to customize the VM. For example to change memory:
		vb.customize ['modifyvm', :id, '--memory', '2048','--cpus', '2','--ioapic', 'on']
	end

	config.vm.provision :puppet do |puppet|
		puppet.manifests_path = 'puppet/manifests'
		puppet.manifest_file  = 'base.pp'
		puppet.module_path    = 'puppet/modules'
		puppet.options = '--hiera_config /vagrant/hiera.yaml'
		puppet.facter = {
			#Example 'apt_proxy' => 'http://10.10.10.10:3142',
			'apt_proxy' => '',
			'fluidtypo3_branch' => 'development',
			'document_root' => DOCUMENT_ROOT,
			'fqdn' => 'dev.fluidtypo3.org',
			'typo3_branch' => 'TYPO3_6-2',
			'operatingsystem' => 'Debian',
			'osfamily' => 'Debian',
			'osversion' => 'wheezy',
		}
	end

end
