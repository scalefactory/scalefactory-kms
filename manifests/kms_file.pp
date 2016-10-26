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
# Wraps up KMS file decrypt logic
#
# This define relies on the aws-sdk-resources gem being installed
#
define kms::kms_file (
    $encrypted_file,
    $target_file    = $title,
    $mode           = nil,
    $owner          = nil,
    $group          = nil,
    $aws_region     = 'eu-west-1',
){
    file{ "${target_file}.enc":
        ensure => present,
        source => $encrypted_file,
        mode   => $mode,
        owner  => $owner,
        group  => $group,
    }

    kms_decrypt_file{ "${target_file}.enc":
        ensure      => present,
        target_file => $target_file,
        require     => File["${target_file}.enc"],
        subscribe   => File["${target_file}.enc"],
        aws_region  => $aws_region,

    }

    file { $target_file:
        mode    => $mode,
        owner   => $owner,
        group   => $group,
        require => Kms_decrypt_file["${target_file}.enc"],
    }

}
