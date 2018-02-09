# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Nginx Port Forwarding
  config.vm.network "forwarded_port", guest: 80, host: 10080

  # Nunaliit Port Forwarding
  config.vm.network "forwarded_port", guest: 8080, host: 9080

  # CouchDB / Futon Port Forwarding
  config.vm.network "forwarded_port", guest: 5984, host: 5984

  # Sync /vagrant (change default behavior to explicitly use rsync )
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  # Symlink /vagrant into the puppet modules folder so it can be loaded like a module
  # config.vm.provision "shell", inline: "mkdir -p /vagrant-nsidc-puppet; ln -sf /vagrant /vagrant-nsidc-puppet/nunaliit"

  config.ssh.forward_x11 = true

  # Apply puppet
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  config.vm.provision :shell do |s|
    s.name = 'apt-get update'
    s.inline = 'apt-get update'
  end
  config.vm.provision :shell do |s|
    s.name = 'link nunaliit as puppet module'
    s.inline = "mkdir -p /vagrant-nsidc-puppet; ln -sf /vagrant /vagrant-nsidc-puppet/nunaliit"
  end
  config.vm.provision :shell do |s|
    s.name = 'librarian-puppet install'
    s.inline = 'cd /vagrant/puppet && librarian-puppet install --path=./modules'
  end
  config.vm.provision :puppet do |puppet|
    puppet.working_directory = '/vagrant'
    puppet.manifests_path = './puppet'
    puppet.manifest_file = 'site.pp'
    puppet.options = '--debug --verbose --detailed-exitcodes --modulepath /vagrant/puppet/modules:/vagrant-nsidc-puppet'
    puppet.environment = VagrantPlugins::NSIDC::Plugin.environment
    puppet.environment_path = './puppet/environments'
    puppet.hiera_config_path = './puppet/hiera.yaml'
  end
end

