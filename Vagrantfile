VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version ">= 1.6.2"

require 'yaml'
Configuration = YAML.load_file('Configuration.yaml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = 'puphpet/debian75-x64'

	# Activate if your box need to be available in local network
	if Configuration['VirtualMachine']['networkBridge']
		config.vm.network 'public_network'
	end

	# Change ip: '172.23.23.23' to run more than one VM or replace it with type: 'dhcp' if you need
	config.vm.network 'private_network', ip: Configuration['VirtualMachine']['ip']

	# If true, then any SSH connections made will enable agent forwarding.
	# Default value: false
	config.ssh.forward_agent = true

	#Disable default mount
	config.vm.synced_folder '.', '/vagrant', :disabled => true
	config.vm.synced_folder 'utils', '/vagrant'

	# If Linux, Mac or Vagrant Windows NFS plugin
	if RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/ || Vagrant.has_plugin?("vagrant-winnfsd")
		config.vm.synced_folder Configuration['Mount']['from'], Configuration['Mount']['to'], id: 'fluidTYPO3', type: 'nfs',
			mount_options: ['rw', 'vers=3', 'tcp']
			# Comment in and run vagrant reload and NFS has a cache server.
			#mount_options: ['rw', 'vers=3', 'tcp', 'fsc']
	else
		# Windows without NFS
		config.vm.synced_folder Configuration['Mount']['from'], Configuration['Mount']['to'], id: 'fluidTYPO3'
	end

	config.vm.provider 'virtualbox' do |vb|
		vb.gui = Configuration['VirtualMachine']['gui']

		# Use VBoxManage to customize the VM. For example to change memory:
		vb.customize ['modifyvm', :id, '--memory', Configuration['VirtualMachine']['memory']]
		vb.customize ['modifyvm', :id, '--cpus', Configuration['VirtualMachine']['cpus']]
		vb.customize ['modifyvm', :id, '--ioapic', 'on']
	end

	config.vm.provision :puppet do |puppet|
		puppet.manifests_path = 'puppet/manifests'
		puppet.manifest_file  = 'base.pp'
		puppet.module_path    = 'puppet/modules'
		puppet.options = '--hiera_config /vagrant/hiera.yaml'
		puppet.facter = {
			'apt_proxy' => Configuration['VirtualMachine']['aptProxy'],
			'fluidtypo3_branch' => Configuration['FluidTYPO3']['branch'],
			'document_root' => Configuration['Mount']['to'],
			'fqdn' => Configuration['VirtualMachine']['domain'],
			'typo3_branch' => Configuration['TYPO3']['branch'],
			'operatingsystem' => 'Debian',
			'osfamily' => 'Debian',
			'osversion' => 'wheezy',
		}
	end
end
