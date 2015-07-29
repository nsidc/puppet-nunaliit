require 'spec_helper'

describe 'puppet-module' do

  let(:facts) { { :operatingsystem => 'Ubuntu' } }

  it { should compile.with_all_deps }

end
