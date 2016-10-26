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

Puppet::Type.newtype(:kms_decrypt_file) do
    desc 'Puppet Type that decrypts a file from KMS alias'
    
    ensurable
    
    newparam(:name, :namevar => true) do
        desc 'Location of encrypted file'
    end
    
    newproperty(:target_file) do
        desc 'File to decrypt contents to'
    end
    
    newparam(:aws_region) do
        desc 'AWS region, defaults to region: eu-west-1'
        defaultto 'eu-west-1'
    end
    
    def refresh
        provider.create
    end

end
