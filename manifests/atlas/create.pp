# = Defined Type: nunaliit::atlas::create
# This class is only intended to be used from within the nunaliit::atlas

define nunaliit::atlas::create (
  $atlas_directory = undef,
  $nunaliit_user = $nunaliit::params::nunaliit_user,
  $nunaliit_version = nunaliit::params::nunaliit_version,
  $couchdb_password = hiera('nunaliit::couchdb_password', $nunaliit::params::couchdb_password)
) {
  include ::nunaliit::params

  # Nunaliit command
  $nunaliit_command = "/opt/nunaliit2-couch-sdk-${nunaliit_version}/bin/nunaliit"

  # Atlas directory
  file { $atlas_directory: 
    require  => Exec["nunaliit-create-${title}"]
  }

  # Atlas User
  user { $nunaliit_user: }

  # nunaliit create
  exec { "nunaliit-create-${title}":
    command => "${nunaliit_command} --atlas-dir ${atlas_directory} create --no-config",
    require => Nunaliit::Install[$nunaliit_version],
    user    => $nunaliit_user,
    creates => $atlas_directory,
  }

  # nunaliit config
  exec { "nunaliit-config-${title}":
    command  => "/usr/bin/yes '' | ${nunaliit_command} --atlas-dir ${atlas_directory} config",
    user    => $nunaliit_user,
    creates => "${atlas_directory}/config/sensitive.properties",
    require => Exec["nunaliit-create-${title}"]
  }

  # set runtime user
  file_line { "nunaliit-runtime-user-${title}":
    path => "${atlas_directory}/extra/nunaliit.sh",
    match => '#?NUNALIIT_USER=.*',
    line => "NUNALIIT_USER=${nunaliit_user}",
    require => Exec["nunaliit-config-${title}"]
  }

  # set couchdb password
  file_line { "couchdb-password-${atlas_directory}":
    path => "${atlas_directory}/config/sensitive.properties",
    match => '^couchdb\.admin\.password=.*',
    line => "couchdb.admin.password=${couchdb_password}",
    require => Exec["nunaliit-config-${title}"]
  }

  # run first nunaliit update after setting CouchDB password
  exec { "nunaliit-first-update-${title}":
    command     => "${nunaliit_command} --atlas-dir ${atlas_directory} update",
    user        => $nunaliit_user,
    require     => Service['couchdb'],
    subscribe   => File_line["couchdb-password-${atlas_directory}"],
    refreshonly => true,
    tries       => 3,
    try_sleep   => 5,
  }
  # At this point we stop. The rest of the process should be the same for existing and new atlases.

}

