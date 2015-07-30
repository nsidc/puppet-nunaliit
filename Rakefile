require 'rake'
require 'rspec/core/rake_task'
require 'json'

import './tasks/spec.rake'

desc "Run all RSpec code examples"
RSpec::Core::RakeTask.new(:rspec) do |t|
  suites = (Dir.entries('spec') - ['.', '..', 'fixtures']).select { |e| File.directory? "spec/#{ e }" }

  t.pattern = suites.map { |s| "spec/#{ s }/**/*_spec.rb" }
end

desc "Run bumpversion"
task :bump, [:part] do |t, args|
  version_filename = 'metadata.json'
  version = JSON.load(File.new(version_filename))['version']

  cmd = "bumpversion --current-version #{version} #{args[:part]} #{version_filename}"
  exec cmd
end

desc "Run parser validation and puppet-lint"
task :lint do
  sh 'puppet parser validate ./manifests/'
  sh 'puppet-lint --no-autoloader_layout-check ./manifests'
end
