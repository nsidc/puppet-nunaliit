# Not necessarily worth the time to research and configure
# beaker RSpec for now.  So we can just do sanity checks by with
# shell commands.
#
# Using rescue logic in this method will make sure that every test
# runs instead of failing the suite of tests prematurely if even one test
# fails.
def integration_test(test_sym, failed_tests)
  yield
rescue
  failed_tests << test_sym
end

namespace :spec do
  desc "Run unit tests"
  task :unit do
    Dir.chdir('puppet')
    sh 'librarian-puppet clean'
    sh 'librarian-puppet install --path=../spec/fixtures/modules'
    Dir.chdir('..')
    sh 'ln -s -f $PWD spec/fixtures/modules/nunaliit'
    sh 'git checkout spec/' # The puppet-install does bad things to spec/...
    sh 'rake rspec'
    sh 'rm -f spec/fixtures/modules/nunaliit' # vagrant uses rsync --copy-links...
  end

  desc "Run integration tests"
  task :integration do
    # These commands aren't part of the test, just doing cleanup and setup.
    sh  'sudo rm -rf ./puppet/.librarian ./puppet/.tmp ./puppet/Puppetfile.lock' # Clean out install garbage

    tests = {
      # Sleep awhile after upping the machine so that the machine is sure to be ready for ssh communication.
      can_provision_machine: proc { sh "vagrant nsidc up --env=integration --provision; sleep 15" },
    }

    failed_tests = []

    tests.each { |test_sym, test_proc| integration_test(test_sym, failed_tests) { test_proc.call } }

    fail "The following integration tests did not pass: #{ failed_tests.join(', ') }" unless failed_tests.size == 0
  end
end
