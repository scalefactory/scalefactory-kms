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

Puppet::Type.type(:kms_decrypt_file).provide(:decrypt) do
    
    def get_kms_client (region=resource[:aws_region])
        begin
            gem 'aws-sdk-resources'
            require 'aws-sdk-resources'            
            Aws::KMS::Client.new(region: region)
        rescue Puppet::ExecutionFailure => e
            Puppet.error("Failed to get IAM connection for AWS region #{region}, error: #{e.inspect}")
            return nil
        end
    end
     
    def decrypt (target_file)
        kms = get_kms_client
        secrets = File.read(target_file, mode: 'rb')
        begin
            kms.decrypt({ciphertext_blob: secrets, }).plaintext
        rescue  Puppet::ExecutionFailure => e
            Puppet.error("Failed to decrypt, error: #{e.inspect}")
            return nil
        end
    end

    # Create a new kms resource
    def create
        File.write(resource[:target_file], decrypt(resource[:name]))
    end

    # Destroy an existing kms resource
    def destroy
        File.delete(target_file) if File.exist?(resource[:target_file])
    end

    # Determine whether a kms resource exists
    def exists?
        if File.exist?(resource[:target_file])
            return true
        else
            return false
        end
    end
    
    def target_file
        resource[:target_file]
    end

    def target_file=(val)
        create
    end

end
