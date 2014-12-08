# This module installs nunaliit
# See https://github.com/GCRC/nunaliit/wiki/Prerequisite-install-on-Ubuntu-14.04-LTS

class nunaliit () inherits nunaliit::params {

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
    line  => "admin = ${nunaliit_couchdb_password}",
    match  => ';?admin = [a-zA-Z]+',
    require => Package['couchdb'],
    notify => Service['couchdb']
  }

  # Install nunaliit tgz from source url
  include puppi
  $nunaliit_tar_url = "http://central.maven.org/maven2/ca/carleton/gcrc/nunaliit2-couch-sdk/${nunaliit_version}/nunaliit2-couch-sdk-${nunaliit_version}-nunaliit.tar.gz"
  puppi::netinstall { 'nunaliit':
    url              => "${nunaliit_tar_url}",
    destination_dir  => "/opt",
    extracted_dir    => "nunaliit2-couch-sdk-${nunaliit_version}"
  }

  # Find any nunaliit atlases defined in hiera data and add them to the manifest
  $nunaliit_atlases = hiera('nunaliit::atlases', {})
  create_resources('nunaliit::atlas', $nunaliit_atlases)

}

