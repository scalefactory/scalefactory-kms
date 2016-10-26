require 'spec_helper'

describe 'sf_kms::eyaml', :type => 'class' do
    
    scripts_dir = File.absolute_path(File.dirname(__FILE__))
    
    let :default_params do  {
        :private_key_source => "file:///#{scripts_dir}/../files/private.pem", 
        :public_key_source => "file:///#{scripts_dir}/../files/public.pem"
    }
    end

    def self.test_standard_behaviour
        # These tests get run in both Debian and RedHat contexts
        #  later on.  Specify any cross-distribution behaviour here.
        
        let :params do
            default_params.merge({})
        end

        it { should compile.with_all_deps }

        it { should contain_class('sf_kms::eyaml') }
        
        it do
            is_expected.to contain_file('/var/lib/puppet/keys/public_key.pkcs7.pem').with({
                'ensure' => 'present',
                'owner'  => 'puppet',
                'group'  => 'root',
                'mode'   => '0440',
            })
        end
       
        it do
            is_expected.to contain_file('/var/lib/puppet/keys/private_key.pkcs7.pem').with({
              # 'ensure' => 'present',
               'owner'  => 'puppet',
               'group'  => 'root',
               'mode'   => '0440',
            })
        end
        
    end
    
    def self.test_custom_location
        # These tests get run in both Debian and RedHat contexts
        #  later on.  Specify any cross-distribution behaviour here.
        
        let :params do
            default_params.merge({
                :puppet_keys_folder => "/tmp/buttons/help"
            })
        end

        it { should compile.with_all_deps }

        it { should contain_class('sf_kms::eyaml') }
        
        it do
            is_expected.to contain_file('/tmp/buttons/help/public_key.pkcs7.pem').with({
                'ensure' => 'present',
                'owner'  => 'puppet',
                'group'  => 'root',
                'mode'   => '0440',
            })
        end
       
        it do
            is_expected.to contain_file('/tmp/buttons/help/private_key.pkcs7.pem').with({
              # 'ensure' => 'present',
               'owner'  => 'puppet',
               'group'  => 'root',
               'mode'   => '0440',
            })
        end
        
    end

    # Now we test specific contexts:
    context "on a Debian OS" do

        include_context "facter"
        include_context "debian_facts"

        # Call the other tests:
        test_standard_behaviour
        #test_custom_location

    end

    context "on a RedHat OS" do

        include_context "facter"
        include_context "redhat_facts"

        # Call the other tests:
        test_standard_behaviour
        #test_custom_location
    end

    context "on a Debian OS with a custom location" do

        include_context "facter"
        include_context "debian_facts"

        # Call the other tests:
        #test_standard_behaviour
        test_custom_location
    end

    context "on a RedHat OS with a custom location" do

        include_context "facter"
        include_context "redhat_facts"

        # Call the other tests:
        #test_standard_behaviour
        test_custom_location
    end

end
