Vagrant.configure(2) do |config|

  # Nunaliit
  config.vm.network "forwarded_port", guest: 8080, host: 9080

  # CouchDB / Futon
  config.vm.network "forwarded_port", guest: 5984, host: 5984

  # Sync the working copy of our puppet module into the right place
  config.vm.synced_folder '.', '/vagrant-nsidc-puppet/nunaliit'

end

