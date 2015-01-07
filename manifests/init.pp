# This module installs versions of the nunaliit couchd sdk and manages nunaliit atlases
# See https://github.com/GCRC/nunaliit/wiki/Prerequisite-install-on-Ubuntu-14.04-LTS

class nunaliit (
  $couchdb_password = $nunaliit::params::couchdb_password,
  $couchdb_data_directory = $nunaliit::params::couchdb_data_directory,
  $atlas_parent_directory = $nunaliit::params::atlas_parent_directory,
  $atlas_source_directory = $nunaliit::params::atlas_source_directory,
) inherits nunaliit::params {

  # $couchdb_log_file = "${couchdb_data_directory}/couch.log"

  # puppet dependency for deep_merging create_resources (only works on the second try)
  package { 'deep_merge':
    ensure   => 'installed',
    provider => 'gem',
  }

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
    require => [ Package['couchdb'], File_line['couchdb_bind'], File_line['couchdb_admin'], File[$couchdb_data_directory] ]
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

  # Setup the CouchDB server log file
  # file_line { 'couchdb_logfile':
  #   path  => '/etc/couchdb/local.ini',
  #   line  => "file = ${couchdb_log_file}",
  #   after  => '\[log\]',
  #   require => [ Package['couchdb'], File[$couchdb_data_directory] ],
  #   notify => Service['couchdb']
  # }

  # Setup the CouchDB database directory
  file { $couchdb_data_directory:
     ensure => 'directory',
     require => Package['couchdb'],
     notify => Service['couchdb'],
     owner => 'couchdb',
  }
  file { '/var/lib/couchdb':
     ensure => 'link',
     target => $couchdb_data_directory,
     force => true,
     require => File[$couchdb_data_directory],
     before  => Service['couchdb'],
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

  # install and configure nginx
  package { 'nginx': }
  file { '/etc/nginx/conf.d/nunaliit.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/nunaliit/nginx.conf',
    require => Package['nginx'],
    notify  => Service['nginx']
  }
  file { '/etc/nginx/sites-available/default':
    ensure  => absent,
    require => Package['nginx'],
    notify => Service['nginx']
  }
  service { 'nginx':
    ensure => running,
    enable => true,
    require => Package[nginx]
  }

  # Find any nunaliit installations defined in hiera data and add them to the manifest
  $nunaliit_installs = hiera_hash('nunaliit::installs', {})
  create_resources('nunaliit::install', $nunaliit_installs)

  # Find any nunaliit atlases defined in hiera data and add them to the manifest
  $nunaliit_atlases = hiera_hash('nunaliit::atlases', {})
  create_resources('nunaliit::atlas', $nunaliit_atlases)

}

