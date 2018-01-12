# = Defined Type: install
# Install a version of nunaliit into /opt

define nunaliit::install (
  $nunaliit_version = $title
) {
  include ::nunaliit::params


  # Install nunaliit tgz from source url
  # TODO: This feature is unfinished, waiting on additional information from Peter.
  # TODO: When finsihing this feature pull the path from a config location for easy updating.
  if $nunaliit_version =~ /.*SNAPSHOT.*/ {
    $nunaliit_tar_path = "/apps/nunaliit/distros/nunaliit2-couch-sdk-${nunaliit_version}.tar.gz"
    file { "/opt/nunaliit2-couch-sdk-${nunaliit_version}":
      ensure => 'directory'
    }
    exec { "tar -xzf ${nunaliit_tar_path} -C /opt/nunaliit2-couch-sdk-${nunaliit_version} --strip-components 1":
      creates => "/opt/nunaliit2-couch-sdk-${nunaliit_version}/bin",
      path    => ['/bin', '/usr/bin', '/usr/sbin',]
    }
  } else {
    $nunaliit_tar_url = "http://central.maven.org/maven2/ca/carleton/gcrc/nunaliit2-couch-sdk/${nunaliit_version}/nunaliit2-couch-sdk-${nunaliit_version}-nunaliit.tar.gz"
    puppi::netinstall { "install-nunaliit-${nunaliit_version}":
      url             => $nunaliit_tar_url,
      destination_dir => '/opt',
      extracted_dir   => "nunaliit2-couch-sdk-${nunaliit_version}"
    }
  }
}

