# = Defined Type: atlas
# Create and/or manage a nunaliit atlas

define nunaliit::atlas (
  $atlas_parent_directory = hiera('nunaliit::atlas_parent_directory',   $nunaliit::params::atlas_parent_directory),
  $atlas_source_directory = hiera('nunaliit::atlas_source_directory',   $nunaliit::params::atlas_source_directory),
  $nunaliit_user          = hiera('nunaliit::nunaliit_user',            $nunaliit::params::nunaliit_user),
  $nunaliit_version       = hiera('nunaliit::nunaliit_default_version', $nunaliit::params::nunaliit_default_version),
  $nunaliit_pkg_prefix    = hiera('nunaliit::pkg_prefix',      $nunaliit::params::pkg_prefix),
  $nunaliit_sh = hiera('nunaliit::nunaliit_script', "nunaliit-${title}.sh"),
  # $nunaliit_sh = hiera('nunaliit::nunaliit_script', 'nunaliit.sh'),
  $port = $nunaliit::params::nunaliit_default_port,
  $create = false,
  $htdocs = true,
  $docs = true,
  $config = true,
  # $site = true
  $site = false
) {
  include ::nunaliit::params

  # Nunaliit command
  $nunaliit_command = "/opt/${nunaliit_pkg_prefix}${nunaliit_version}/bin/nunaliit"

  # atlas directory must be named consistently
  $atlas_directory = "${atlas_parent_directory}/${title}"

  # Setup the atlas init script
  file { 'nunaliit_systemd_config':
    content => template('files/nunaliit.erb'),
    path    => "/etc/systemd/system/nunaliit-${title}.service",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$atlas_directory]
  }

  # Sometimes we need to wait a few seconds before Nunaliit can talk to CouchDB
  exec { "wait-for-couchdb-${title}":
    command     => 'sleep 5',
    path        => '/usr/local/bin:/usr/bin:/bin',
    refreshonly => true,
    subscribe   => Service['couchdb'],
  }

  # TEMPORARY (2015-08-04)
  # I renamed the nunaliit service from "${title}" to "nunaliit-${title}"
  # This exec statement disables the legacy service when the new one is enabled.
  # exec{ "disable-legacy-nunaliit-service-${title}":
  #   command     => "update-rc.d -f ${title} remove",
  #   path        => '/usr/sbin',
  #   refreshonly => true,
  # }

  # If we were asked to create the atlas, do that before starting the service
  if $create == true {

    # Create the atlas (and atlas directory)
    nunaliit::atlas::create { $title:
      atlas_directory  => $atlas_directory,
      nunaliit_user    => $nunaliit_user,
      nunaliit_version => $nunaliit_version,
    }

    # Setup the Nunaliit service
    # service { "nunaliit-${title}":
    #   ensure  => 'running',
    #   enable  => true,
    #   # status  => "/etc/init.d/nunaliit-${title}.service check",
    #   require => [
    #     Exec["wait-for-couchdb-${title}"],
    #     Service['couchdb'],
    #     File["/etc/init.d/nunaliit-${title}.service"],
    #     Nunaliit::Atlas::Create[$title]
    #   ],
    #   notify  => Exec["disable-legacy-nunaliit-service-${title}"],
    # }

    service { "nunaliit-${title}":
      ensure  => running,
      enable  => true,
      require => [
        Exec["wait-for-couchdb-${title}"],
        Service['couchdb'],
        File['nunaliit_systemd_config'],
        Nunaliit::Atlas::Create[$title]
    }

  # Otherwise, just start the service
  } else {

    # Identify atlas directory (should already exist)
    file { $atlas_directory: }

    # Setup the Nunaliit service
    service { "nunaliit-${title}":
      ensure  => running,
      enable  => true,
      require => [
        Exec["wait-for-couchdb-${title}"],
        Service['couchdb'],
        File['nunaliit_systemd_config'],
    }
  }

  # Update CouchDB with the data from the atlas directory when notified
  exec { "nunaliit-update-${title}":
    command     => "${nunaliit_command} --atlas-dir ${atlas_directory} update",
    user        => $nunaliit_user,
    refreshonly => true,
    require     => Service["nunaliit-${title}"]
  }

  # Sync the docs folder removing any other existing files
  # then run nunaliit update
  if $docs {
    file{ "${atlas_directory}/docs":
      ensure  => directory,
      owner   => $nunaliit_user,
      recurse => true,
      purge   => true,
      force   => true,
      source  => "${atlas_source_directory}/${title}/docs",
      require => Service["nunaliit-${title}"],
      notify  => Exec["nunaliit-update-${title}"]
    }
  }

  # Sync the htdocs folder removing any other existing files
  # then run nunaliit update
  if $htdocs {
    file{ "${atlas_directory}/htdocs":
      ensure  => directory,
      owner   => $nunaliit_user,
      recurse => true,
      purge   => true,
      force   => true,
      source  => "${atlas_source_directory}/${title}/htdocs",
      require => Service["nunaliit-${title}"],
      notify  => Exec["nunaliit-update-${title}"]
    }
  }

  # Sync the the site folder, but leave any other existing files
  # then run nunaliit update
  if $site {
    file{ "${atlas_directory}/site":
      ensure  => directory,
      owner   => $nunaliit_user,
      recurse => true,
      force   => true,
      source  => "${atlas_source_directory}/${title}/site",
      require => Service["nunaliit-${title}"],
      notify  => Exec["nunaliit-update-${title}"]
    }
  }

  # Sync the the config folder, but leave any other existing files
  # then restart the nunaliit service
  if $config {
    file{ "${atlas_directory}/config":
      ensure  => directory,
      owner   => $nunaliit_user,
      recurse => true,
      source  => "${atlas_source_directory}/${title}/config",
      require => File[$atlas_directory],
      notify  => Service["nunaliit-${title}"],
    }
  }

  # Change the atlas port, then restart the service
  unless $port == undef {
    file_line { "atlas-port-${title}":
      path    => "${atlas_directory}/config/install.properties",
      line    => "servlet.url.port=${port}",
      match   => 'servlet\.url\.port=.*',
      require => File[$atlas_directory],
      notify  => Service["nunaliit-${title}"],
    }
  }

}

