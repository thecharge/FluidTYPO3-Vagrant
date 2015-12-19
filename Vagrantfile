VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version ">= 1.6.2"

require 'yaml'



Configuration = YAML.load(File.open(File.join(File.dirname(__FILE__), 'Configuration.sample.yaml'), File::RDONLY).read)
if File.file?File.join(File.dirname(__FILE__),'Configuration.yaml')
else
	require 'fileutils'
	FileUtils.cp(File.join(File.dirname(__FILE__),'Configuration.sample.yaml'),File.join(File.dirname(__FILE__),'Configuration.yaml'))
	puts('Configuration.yaml was missing. The Configuration.sample.yaml got copied')
end

begin
	Configuration.merge!(YAML.load(File.open(File.join(File.dirname(__FILE__), 'Configuration.yaml'), File::RDONLY).read))
end

# Check for missing plugins
required_plugins = %w(vagrant-hostsupdater vagrant-vbguest)
plugin_installed = false
required_plugins.each do |plugin|
	unless Vagrant.has_plugin?(plugin)
		system "vagrant plugin install #{plugin}"
		plugin_installed = true
	end
end

# If new plugins installed, restart Vagrant process
if plugin_installed === true
	exec "vagrant #{ARGV.join' '}"
end

system("
    if [ #{ARGV[0]} = 'up' ]; then
        #{File.dirname(__FILE__)}/utils/composer.sh #{File.dirname(__FILE__)}/#{Configuration['Mount']['from']}
    fi
")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = 'debian/jessie64'

	config.vm.hostname = Configuration['VirtualMachine']['domain'] ||= 'dev.fluidtypo3.org'
	config.hostsupdater.remove_on_suspend = true

	# Activate if your box need to be available in local network
	if Configuration['VirtualMachine']['networkBridge'] ||= false
		config.vm.network 'public_network'
	end

	# Change ip: '172.23.23.23' to run more than one VM or replace it with type: 'dhcp' if you need
	config.vm.network 'private_network', ip: Configuration['VirtualMachine']['ip'] ||= '172.23.23.23'

	#Disable default mount
	config.vm.synced_folder '.', '/vagrant', :disabled => true
	config.vm.synced_folder 'utils', '/vagrant'

	# If Linux, Mac or Vagrant Windows NFS plugin
	if RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/ || Vagrant.has_plugin?("vagrant-winnfsd")
		if Configuration['VirtualMachine']['fsc'] ||= false
			config.vm.synced_folder Configuration['Mount']['from'] ||= 'www', Configuration['Mount']['to'] ||= '/var/www', id: 'fluidTYPO3', type: 'nfs',
					mount_options: ['rw', 'vers=3', 'udp', 'noatime', 'fsc']
		else
			config.vm.synced_folder Configuration['Mount']['from'] ||= 'www', Configuration['Mount']['to'] ||= '/var/www', id: 'fluidTYPO3', type: 'nfs',
					mount_options: ['rw', 'vers=3', 'udp', 'noatime']
		end
	else
		# Windows without NFS
		config.vm.synced_folder Configuration['Mount']['from'] ||= 'www', Configuration['Mount']['to'] ||= '/var/www', id: 'fluidTYPO3'
	end

	config.vm.provider 'virtualbox' do |vb|
		vb.gui = Configuration['VirtualMachine']['gui'] ||= false

		# Use VBoxManage to customize the VM. For example to change memory:
		vb.customize ['modifyvm', :id, '--memory', Configuration['VirtualMachine']['memory'] ||= '2048']
		vb.customize ['modifyvm', :id, '--cpus', Configuration['VirtualMachine']['cpus'] ||= '2']
		vb.customize ['modifyvm', :id, '--ioapic', 'on']
  end

	config.vm.provision 'shell', inline: 'apt-get install --yes puppet &> /dev/null'

	config.vm.provision :puppet do |puppet|
		puppet.synced_folder_type = "nfs"
		puppet.manifests_path = 'puppet/manifests'
		puppet.module_path    = 'puppet/modules'
		if Configuration['VirtualMachine']['puppetDebug'] ||= false
			puppet.options = '--debug --verbose --hiera_config /vagrant/hiera.yaml'
		else
			puppet.options = '--hiera_config /vagrant/hiera.yaml'
		end
		puppet.facter = {
				:apt_proxy => Configuration['VirtualMachine']['aptProxy'] ||= '',
				:document_root => Configuration['Mount']['to'] ||= '/var/www',
				:fqdn => Configuration['VirtualMachine']['domain'] ||= 'dev.fluidtypo3.org',
				:operatingsystem => 'Debian',
				:osfamily => 'Debian',
				:osversion => 'jessie',
		}
	end
	config.vm.provision 'shell', path: 'utils/afterStart.sh',  :privileged => false, :run => 'always'
end
