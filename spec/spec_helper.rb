require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera-puppet-helper'
require 'yaml'
require 'ci/reporter/rake/rspec_loader'

# Report cleanup
FileUtils.rm_rf 'spec/reports'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  # Enable colour in Jenkins
  c.tty = true
  # Readable test descriptions
  c.formatter = :documentation
  # Output for Junit
  c.formatter = CI::Reporter::RSpecFormatter
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
    Puppet[:data_binding_terminus] = 'none' 
    # work around https://tickets.puppetlabs.com/browse/PUP-1547
    # ensure that there's at least one provider available by emulating that any command exists
    require 'puppet/confine/exists'
    Puppet::Confine::Exists.any_instance.stubs(:which => '')
  end
  # Explicitly enable `should` syntax to resolve deprecation warnings
  c.mock_with :rspec do |config|
    config.syntax = [:should, :expect]
  end
end

# use both rpsec and yaml backends .. see: https://github.com/bobtfish/hiera-puppet-helper#advanced
shared_context "hieradata" do
  let(:hiera_config) do
    { :backends => ['rspec', 'yaml'],
    :hierarchy => [
      '%{fqdn}/%{calling_module}',
      '%{calling_module}',
      'common'],
    :yaml => {
      :datadir => File.join(fixture_path, 'hieradata') },
    :rspec => respond_to?(:hiera_data) ? hiera_data : {} }
  end
end

shared_context "facter" do
  let(:default_facts) {{
    :kernel => 'Linux',
    :concat_basedir => '/dne',
    :architecture => 'x86_64',
    :cache_bust => Time.now,
  }}
end

shared_context "debian_facts" do
  let(:facts) { default_facts.merge({
    :osfamily => 'Debian',
    :operatingsystem => 'Ubuntu',
    :lsbdistcodename => 'precise',
    :lsbdistid => 'Ubuntu',
  })}
end

shared_context "redhat_facts" do
  let(:facts) { default_facts.merge({
    :osfamily => 'RedHat',
    :operatingsystem => 'CentOS',
  })}
end
