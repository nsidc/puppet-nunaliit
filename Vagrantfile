Vagrant.configure(2) do |config|

  # Nunaliit Port Forwarding
  config.vm.network "forwarded_port", guest: 8080, host: 9080

  # CouchDB / Futon Port Forwarding
  config.vm.network "forwarded_port", guest: 5984, host: 5984

  # Sync the source of our puppet module into the right place to test it
  config.vm.synced_folder '.', '/vagrant-nsidc-puppet/nunaliit'

end

