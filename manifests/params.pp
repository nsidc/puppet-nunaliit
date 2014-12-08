# = Class nunaliit::params
#
# This class handles the parameters for the nunaliit module.

class nunaliit::params
{
  # Install NFS client packages to enable NFS mounts
  case $::operatingsystem {
    'Ubuntu': {
      $do_nothing = ""
    }
    default: {
      fail("Do not know how to setup the ${module_name} module on an ${::osfamily} based system.")
    }
  }

  # Nunaliit defaults
  $nunaliit_version = '2.2.3'
  $nunaliit_command = "/opt/nunaliit2-couch-sdk-${nunaliit_version}/bin/nunaliit"
  $nunaliit_couchdb_password = 'Silalirjiit'

}

