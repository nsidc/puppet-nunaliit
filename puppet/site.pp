# Load modules and classes
lookup('classes', {merge => unique}).include

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
