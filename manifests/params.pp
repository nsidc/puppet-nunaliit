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
  $nunaliit_user = 'vagrant'
  $nunaliit_default_version = '2.2.3'
  $nunaliit_default_port = '8080'
  $atlas_parent_directory = '/tmp'
  $atlas_source_directory = '/vagrant/atlases'
  $basic_auth = false
  $couchdb_password = 'Silalirijiit'
  $couchdb_data_directory = '/tmp/couchdb'
  $pkg_prefix = 'nunaliit_'
  $snapshot_tarball_base_url = 'https://api.bitbucket.org/2.0/repositories/nsidc/eloka-nunaliit-snapshots/downloads'
}

