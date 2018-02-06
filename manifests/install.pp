# = Defined Type: install
# Install a version of nunaliit into /opt

define nunaliit::install (
  $nunaliit_version = $title,
  $nunaliit_pkg_prefix = hiera('nunaliit::pkg_prefix', $nunaliit::params::pkg_prefix),
  $nunaliit_snapshot_tarball_base_url = hiera('nunaliit::snapshot_tarball_base_url', $nunaliit::params::snapshot_tarball_base_url),
  $nunaliit_app_key_user = hiera('nunaliit::snapshot_app_user', $nunaliit::params::snapshot_app_user),
  $nunaliit_app_key_password = hiera('nunaliit::snapshot_app_password', $nunaliit::params::snapshot_app_password)
) {
  include ::nunaliit::params

  # Install nunaliit tgz from source url
  if $nunaliit_version =~ /.*SNAPSHOT.*/ {
    $nunaliit_tar_url = "${nunaliit_snapshot_tarball_base_url}/nunaliit_${nunaliit_version}.tar.gz"
    puppi::netinstall { "install-nunaliit-${nunaliit_version}":
      retrieve_command => 'curl',
      retrieve_args => "-s -L -O -u ${nunaliit_app_key_user}:${nunaliit_app_key_password}",
      url => $nunaliit_tar_url,
      destination_dir => '/opt',
      extracted_dir   => "${nunaliit_pkg_prefix}${nunaliit_version}"
    }
  } else {
    $nunaliit_tar_url = "http://central.maven.org/maven2/ca/carleton/gcrc/nunaliit2-couch-sdk/${nunaliit_version}/nunaliit2-couch-sdk-${nunaliit_version}-nunaliit.tar.gz"
    puppi::netinstall { "install-nunaliit-${nunaliit_version}":
      url             => $nunaliit_tar_url,
      destination_dir => '/opt',
      extracted_dir   => "${nunaliit_pkg_prefix}${nunaliit_version}"
    }
  }

