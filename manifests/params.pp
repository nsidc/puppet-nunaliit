# = Class nunaliit::params
#
# This class handles the parameters for the nunaliit module.

class nunaliit::params
{
  case $::operatingsystem {
    'Ubuntu': {}
    default: {
      fail("Do not know how to setup the ${module_name} module on an ${::osfamily} based system.")
    }
  }

  # Nunaliit class defaults
  $nunaliit_version = '2.2.3'
  $nunaliit_user = 'vagrant'
  $couchdb_password = 'Silalirijiit'

}

