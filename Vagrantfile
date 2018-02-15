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
  config.vm.provision "shell", inline: "mkdir -p /vagrant-nsidc-puppet; ln -sf /vagrant /vagrant-nsidc-puppet/nunaliit"

  config.vm.provision :shell do |s|
    s.name = 'apt-get update'
    s.inline = 'apt-get update'
  end

  # Apply puppet
  config.vm.provision :nsidc_puppet

end

