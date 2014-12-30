Vagrant.configure(2) do |config|

  # Nunaliit Port Forwarding
  config.vm.network "forwarded_port", guest: 8080, host: 9080

  # CouchDB / Futon Port Forwarding
  config.vm.network "forwarded_port", guest: 5984, host: 5984

  # Use rsync to sync the vagrant workspace to /vagrant
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  # Sync the source of our puppet module into the right place to test it
  config.vm.synced_folder '.', '/vagrant-nsidc-puppet/nunaliit', type: "rsync"

end

