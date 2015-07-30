require 'spec_helper'

describe 'puppet-nunaliit' do

  let(:facts) { { :operatingsystem => 'Ubuntu' } }

  it { should compile.with_all_deps }

end
