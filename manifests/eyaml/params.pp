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
class kms::eyaml::params {
    $puppet_keys_folder = '/var/lib/puppet/keys'
    $private_key_source = nil
    $public_key_source  = nil
    $aws_region         = 'eu-west-1'
}
