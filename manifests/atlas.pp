# = Defined Type: atlas
# Create and/or manage a nunaliit atlas

define nunaliit::atlas (
  $atlas_parent_directory = 
     hiera('nunaliit::atlas_parent_directory', 
     $nunaliit::params::atlas_parent_directory),
  $atlas_source_directory = 
     hiera('nunaliit::atlas_source_directory', 
     $nunaliit::params::atlas_source_directory),
  $nunaliit_user = 
     hiera('nunaliit::nunaliit_user', 
     $nunaliit::params::nunaliit_user),
  $nunaliit_version = 
     hiera('nunaliit::nunaliit_default_version', 
     $nunaliit::params::nunaliit_default_version),
  $port = $nunaliit::params::nunaliit_default_port,
  $create = false,
  $htdocs = true,
  $docs = true,
  $config = true,
) {
  include ::nunaliit::params

  # Nunaliit command
  $nunaliit_command = "/opt/nunaliit2-couch-sdk-${nunaliit_version}/bin/nunaliit"

  # atlas directory must be named consistently
  $atlas_directory = "${atlas_parent_directory}/${title}"

  # Setup the atlas init script
  file { "/etc/init.d/${title}":
    ensure => 'link',
    target => "${atlas_directory}/extra/nunaliit.sh",
    require => File[$atlas_directory]
  }

  # If we were asked to create the atlas, do that before starting the service
  if $create == true {

    # Create the atlas (and atlas directory)
    nunaliit::atlas::create {"$title":
      atlas_directory => $atlas_directory,
      nunaliit_user => $nunaliit_user,
      nunaliit_version => $nunaliit_version,
    }

    # Setup the Nunaliit service
    service { $title:
      ensure => 'running',
      enable => true,
      status => "/etc/init.d/${title} check",
      require => [ Service['couchdb'], File["/etc/init.d/${title}"], Nunaliit::Atlas::Create[$title] ],
    }

  # Otherwise, just start the service
  } else {

    # Identify atlas directory (should already exist)
    file { $atlas_directory: }

    # Setup the Nunaliit service
    service { $title:
      ensure => 'running',
      enable => true,
      status => "/etc/init.d/${title} check",
      require => [ Service['couchdb'], File["/etc/init.d/${title}"] ]
    }
  }

  # Update CouchDB with the data from the atlas directory when notified
  exec { "nunaliit-update-${title}":
    command     => "${nunaliit_command} --atlas-dir ${atlas_directory} update",
    user        => $nunaliit_user,
    refreshonly => true,
    require     => Service[$title]
  }

  # Sync the docs folder removing any other existing files
  # then run nunaliit update
  if $docs {
    file{ "${atlas_directory}/docs":
      ensure  => directory,
      owner   => $nunaliiit_user,
      recurse => true,
      purge   => true,
      force   => true,
      source  => "${atlas_source_directory}/${title}/docs",
      require => Service[$title],
      notify  => Exec["nunaliit-update-${title}"]
    }
  }

  # Sync the htdocs folder removing any other existing files
  # then run nunaliit update
  if $htdocs {
    file{ "${atlas_directory}/htdocs":
      ensure  => directory,
      owner   => $nunaliiit_user,
      recurse => true,
      purge   => true,
      force   => true,
      source  => "${atlas_source_directory}/${title}/htdocs",
      require => Service[$title],
      notify  => Exec["nunaliit-update-${title}"]
    }
  }

  # Sync the the config folder, but leave any other existing files
  # then restart the nunaliit service
  if $config {
    file{ "${atlas_directory}/config":
      ensure  => directory,
      owner   => $nunaliiit_user,
      recurse => true,
      source  => "${atlas_source_directory}/${title}/config",
      require => File[$atlas_directory],
      notify  => Service[$title],
    }
  }

  # Change the atlas port, then restart the service
  unless $port == undef {
    file_line { "atlas-port-$title":
      path => "${atlas_directory}/config/install.properties",
      line => "servlet.url.port=${port}",
      match => 'servlet\.url\.port=.*',
      require => File[$atlas_directory],
      notify  => Service[$title],
    }
  }

}

