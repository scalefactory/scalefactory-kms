# scalefactory-kms

This is an open source project published by The Scale Factory.

We currently consider this project to be archived.

:warning: We’re no longer using or working on this project. It remains available for posterity or reference, but we’re no longer accepting issues or pull requests.

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with scalefactory-kms](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kms](#beginning-with-kms)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

Allow the use of KMS, in particular to secure hiera-eyaml private keys.

This has been tested on Centos 6

## Setup

### Setup Requirements

KMS setup with a Key
Some files encrypted with KMS that need decrypting
The gem `aws-sdk-resources` => 2.2.34 is installed and available to puppet

### Beginning with scalefactory-kms

You need a KMS key set up, and the servers role needs to be able to decrypt with 
the KMS key, an example of the policy on the key might be:

```json
{
  "Sid": "Allow use of the key",
  "Effect": "Allow",
  "Principal": {
    "AWS": [
      "arn:aws:iam::111111111111:role/sf_default_role",
      "arn:aws:iam::111111111111:role/sf_jenkins_role",
    ]
  },
  "Action": [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*",
    "kms:DescribeKey"
  ],
  "Resource": "*"
},
{
  "Sid": "Allow attachment of persistent resources",
  "Effect": "Allow",
  "Principal": {
    "AWS": [
      "arn:aws:iam::111111111111:role/sf_default_role",
      "arn:aws:iam::111111111111:role/sf_jenkins_role",
    ]
  },
  "Action": [
    "kms:CreateGrant",
    "kms:ListGrants",
    "kms:RevokeGrant"
  ],
  "Resource": "*",
  "Condition": {
    "Bool": {
      "kms:GrantIsForAWSResource": "true"
    }
  }
}
```
 
In the hiera.yaml file add the following backend:

```yaml
:backends:
    - eyaml
```

Add the following to the bottom:

```yaml
:eyaml:
    :datadir: /etc/puppet/<site>/hieradata
    :pkcs7_private_key: /var/lib/puppet/keys/private_key.pkcs7.pem
    :pkcs7_public_key:  /var/lib/puppet/keys/public_key.pkcs7.pem
    :extension: 'yaml'
```

A script is provided in the root called `create_kms` which will use the aws cli 
to create a KMS Key for you and encrypt your private key.

Example:
You can run the create_kms script with the dryrun flag to see what it will create.

```sh
scripts/create_kms -p mgmt_profile --keyusers role/sf_default_role -t ~/sf-kms --dryrun
```

The create_eyaml_keys will create a pair of keys to use, be default it will
delete the private key.

```sh
scripts/create_eyaml_keys -p mgmt_profile 
```
    
If you would like to save the keys locally, so you can say add to a password
vault or use the same key across each environment then this work flow would
work:

```sh
scripts/create_eyaml_keys -p mgmt_profile -t ~/sf-kms  --nodelete
# encrypted keys in ~/sf-kms, unencrypted keys in ~/sf-kms/keys
# now encrypt for test account
scripts/encrypt -p test_profile -i ~/sf-kms/keys/private_key.pkcs7.pem -o ~/sf-kms/test_private.pem
# now encrypt for live account
scripts/encrypt -p live_profile -i ~/sf-kms/keys/private_key.pkcs7.pem -o ~/sf-kms/live_private.pem
```

Note the ruby SDK uses the ~/.aws/credentials file so will only support
`aws_access_key_id, aws_secret_access_key, aws_session_token`. If you are using
roles with your user you can use the --assumerole flag to assume a role your
account has access to. e.g.

```sh
scripts/encrypt -p profile_name -i ~/sf-kms/keys/private_key.pkcs7.pem -o ~/sf-kms/test_private.pem --assumerole 'arn:aws:iam::111111111111111:role/role_name'
```

If you need to provide 2FA when assuming a role, then the following will help:

```sh
scripts/encrypt -p profile_name -i ~/sf-kms/keys/private_key.pkcs7.pem -o ~/sf-kms/test_private.pem --assumerole arn:aws:iam::111111111111111:role/role_name --serial arn:aws:iam::00000000000:mfa/user --token 133182
```

## Usage

Example usage:

```puppet
class { 'kms::eyaml':
    private_key_source => "puppet:///modules/xx_kms/${::sf_environment}private.key",
    public_key_source  => "puppet:///modules/xx_kms/${::sf_environment}public.key",
}
```

To generate your private keys use the create_eyaml_keys script as above. You can
use the same or different keys across environments.

### Encrypting hiera entries

To encrypt hiera entries see the notes [here](
https://github.com/TomPoulton/hiera-eyaml). In brief:

Create a `~/.eyaml/config.yaml` file with entires like the following:

```yaml
---
pkcs7_public_key: '~/keys/eyaml/public_key.pkcs7.pem'
```

With the path set to the location of your public key.

To encrypt something, you only need the public_key, so distribute that to people
creating hiera properties

```sh
$ eyaml encrypt -s 'hello there'       # Encrypt a string
$ eyaml encrypt -p                     # Encrypt a password (prompt for it)
```

Use the -l parameter to pass in a label for the encrypted value,

```sh
$ eyaml encrypt -l 'some_easy_to_use_label' -s 'yourSecretString'
```

To decrypt something, you need the public_key and the private_key.

To test decryption you can also use the eyaml tool if you have both keys

```sh
$ eyaml decrypt -f filename               # Decrypt a file
$ eyaml decrypt -s 'ENC[PKCS7,.....]'     # Decrypt a string
```

The encrypted string goes into the hiera yaml file as follows:

```yaml
---
plain-property: You can see me

cipher-property : >
ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
/HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]

cipher-property-2: "ENC[PKCS7,MIIBiQYJKoa4WRHrZnwYz0kB+hXipNihvUb3PqNMl/19GBbl4iG5144jIzR6L7WCB+URvQTzBMBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBA/0bQl+Q5hzR+TRcCbLcdxgCA0Ibr5ZQ1xg2bU7uifGcqvsSH1KR9VXQ/OAftBiOiqVw==]"
```

You can also edit a file in place using:

```sh
$ eyaml edit filename.eyaml         # Edit an eyaml file in place
```

If you use the [Atom](https://atom.io/) editor there is a [hiera-eyaml
plugin](https://atom.io/packages/hiera-eyaml) that you can use to encrypt
selected text with a right click.

## Limitations

CentOS 6 tested only

Requires that aws-sdk-resources gem is installed on puppet servers.

Requires you to set up KMS key outside of this module.

Requires you to encrypt any files outside of this module.

The module should be called during the bootstrap process and also during normal
puppet runs. Make sure your not using any encrypted values in your boot
strapping process or it won't work. Need encrypted value in your bootstrap?
Consider [hiera-eyaml-kms](https://github.com/adenot/hiera-eyaml-kms). This will
call KMS for each decrypt call, so you can easily hit the rate limit when
running puppet across an estate with multiple decrypts, thus this module.


## Type/Providers

A type is provided to wrap up decrypting a file:

```puppet
kms::kms_file { "/tmp/private_key.pkcs7.pem":
    encrypted_file => "puppet:///modules/sf_example/private.key",
    mode           => '0440',
    owner          => 'puppet',
    group          => 'root',
}
```

You can also use the KMS provider to decrypt files, e.g.

```puppet
file{ '/tmp/encrypted':
    source  => 'puppet:///modules/sf_example/secret.out',
}

kms_decrypt_file{ '/tmp/encrypted':
    ensure      => present,
    target_file => '/tmp/testy',
    require     => File['/tmp/encrypted'],
    subscribe   => File['/tmp/encrypted'],
}
    

file{ '/tmp/testy':
    mode    => '0777',
    require => Kms_decrypt['/tmp/encrypted'],
}
```
