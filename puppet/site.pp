# Load puppet options from vagrant-nsidc.yaml
$puppet = hiera_hash('puppet')
$puppet_options = $puppet['apply']['options']
$puppet_manifest = $puppet['apply']['manifest']

# Load modules and classes
hiera_include('classes')

if $environment == 'ci' {
  # ci machine needs some python dependencies to install bumpversion,
  # which can be used as a common way to bump versions for any project.
  class { 'python':
    version => 'system',
    pip     => true,
    dev     => true # Needed for fabric
  }

  python::pip { 'bumpversion':
    pkgname => 'bumpversion',
    ensure  => '0.5',
    owner   => 'root'
  }

  # Testing dependencies
  package { 'rake':
    provider => 'gem'
  }
  package { 'rspec':
    provider => 'gem'
  }
  package { 'rspec-puppet':
    provider => 'gem'
  }
  package { 'puppet-lint':
    provider => 'gem'
  }

}
