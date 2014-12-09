# = Defined Type: atlas

define nunaliit::atlas (
  $create = 'true',
  $atlas_directory = undef,
) {

  include ::nunaliit::params

  # Wait for Jenkins to be ready
  if $create == "true" {
    exec { "nunaliit-create-$title":
      command   => "${nunaliit::params::nunaliit_command} create ${title}",
      require   => Puppi::Netinstall['nunaliit']
    }
  }

}
