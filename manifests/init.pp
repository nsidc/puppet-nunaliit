# This module installs versions of the nunaliit couchd sdk and manages nunaliit atlases
# See https://github.com/GCRC/nunaliit/wiki/Prerequisite-install-on-Ubuntu-14.04-LTS

class nunaliit (
  $couchdb_password = $nunaliit::params::couchdb_password
) inherits nunaliit::params {

  # Install nunaliit dependencies
  package{ "couchdb": }
  package{ "imagemagick": }
  package{ "openjdk-7-jre-headless": }
  package{ "libav-tools": }
  package{ "ubuntu-restricted-extras": }
  package{ "libavcodec-extra-54": }
  package{ "libavformat-extra-54": }

  # Ensure the CouchDB server is running and set to start on boot
  service { 'couchdb':
    ensure => 'running',
    enable => 'true',
    require => Package['couchdb']
  }

  # Setup the CouchDB server to listen to external requests
  file_line { 'couchdb_bind':
    path => '/etc/couchdb/local.ini',
    line => 'bind_address = 0.0.0.0',
    match => ';?bind_address = .*',
    require => Package['couchdb'],
    notify => Service['couchdb']
  }

  # Setup the CouchDB server admin account
  file_line { 'couchdb_admin':
    path  => '/etc/couchdb/local.ini',
    line  => "admin = ${couchdb_password}",
    match  => ';?admin = [a-zA-Z]+',
    require => Package['couchdb'],
    notify => Service['couchdb']
  }

  # Configure mime types in /etc/magic
  file {'nunaliit-magic':
    ensure => present,
    path   => '/tmp/nunaliit-magic',
    source => 'puppet:///modules/nunaliit/magic',
  }
  exec { "/bin/cat /tmp/nunaliit-magic >> /etc/magic":
    require => File['nunaliit-magic'],
    unless  => "/bin/grep nunaliit /etc/magic"
  }

  # We use puppi for the nunaliit installs from tgz
  class {'puppi':
    install_dependencies => false,
  }

  # Find any nunaliit installations defined in hiera data and add them to the manifest
  $nunaliit_installs = hiera_hash('nunaliit::installs', {})
  create_resources('nunaliit::install', $nunaliit_installs)

  # Find any nunaliit atlases defined in hiera data and add them to the manifest
  $nunaliit_atlases = hiera_hash('nunaliit::atlases', {})
  create_resources('nunaliit::atlas', $nunaliit_atlases)

}

