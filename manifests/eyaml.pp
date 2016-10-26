#
# Copyright 2016 The Scale Factory Limited
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of 
# the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#
# This module relies on the aws-sdk-resources gem being installed
#
class kms::eyaml (
    $puppet_keys_folder = $::kms::eyaml::params::puppet_keys_folder,
    $aws_region         = $::kms::eyaml::params::aws_region,

    # this private key is expected to be encrypted with KMS
    $private_key_source = $::kms::eyaml::params::private_key_source,
    $public_key_source  = $::kms::eyaml::params::public_key_source,

) inherits kms::eyaml::params{

    file { $puppet_keys_folder:
        ensure => directory,
        mode   => '0550',
        owner  => 'puppet',
        group  => 'root',
    }

    file { "${puppet_keys_folder}/public_key.pkcs7.pem":
        ensure  => present,
        source  => $public_key_source,
        mode    => '0440',
        owner   => 'puppet',
        group   => 'root',
        require => File[$puppet_keys_folder],
    }

    ::kms::kms_file { "${puppet_keys_folder}/private_key.pkcs7.pem":
        encrypted_file => $private_key_source,
        mode           => '0440',
        owner          => 'puppet',
        group          => 'root',
        require        => File[$puppet_keys_folder],
        aws_region     => $aws_region,
    }

}
