# = Defined Type: install
# Install a version of nunaliit into /opt

define nunaliit::install (
  $nunaliit_version = $title
) {
  include ::nunaliit::params

  # Install nunaliit tgz from source url
  $nunaliit_tar_url = "http://central.maven.org/maven2/ca/carleton/gcrc/nunaliit2-couch-sdk/${nunaliit_version}/nunaliit2-couch-sdk-${nunaliit_version}-nunaliit.tar.gz"
  puppi::netinstall { "install-nunaliit-${nunaliit_version}":
    url             => $nunaliit_tar_url,
    destination_dir => '/opt',
    extracted_dir   => "nunaliit2-couch-sdk-${nunaliit_version}"
  }

}

