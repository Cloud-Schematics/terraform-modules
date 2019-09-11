# terraform_modules

This project to develop terraform modules which are re-used across payloads. It also includes scripts which are used in the modules for different payloads.

## Licenses and Copyright

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Licensed Materials - Property of IBM

 ©Copyright IBM Corp. 2017.

## Modules

#### virtual_guest

This module is to provision a VM in SoftLayer and run scripts/commands in the newly provisioned VM.

The following scripts/commands executed in the VM sequentially:
* the script to install software
  * (optional) specified varaibles
  * (optional) specified url for sample application tarball
* the commands to remove temporary public key, if required
* the custom commands

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| hostname |  | The hostname of virtual guest |
| domain |  | The domain of virtual guest |
| datacenter |  | The data center where virtual guest is provisoned |
| os_reference_code |  | The operating system code in SoftLayer |
| cores |  | The number of CPU cores |
| memory |  | The memory size in GB |
| disk_size |  | The size of the disk |
| private_network_only | false |  |
| network_speed | 100 | The speed of the network |
| tags |  | Tags to the VM instance |
| ssh_user | root | The user for ssh to the virtual guest |
| ssh_label |  | Name to the SSH Key |
| ssh_notes |  | Notes for the SSH Key |
| public_key |  | public SSH key to use in keypair |
| private_key |  | private SSH key to use in keypair |
| install_script | files/default.sh | The script to install software, used in the module |
| script_variables |  | The variables of the script to install software |
| sample_application_url | "" | The url of sample application tarballs used in the script |
| custom_commands | sleep 1 | The custom commands |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| public_ip | The public ip of virtual guest |

#### cluster

This module is to provision a cluster VM in SoftLayer and run scripts/commands in the newly provisioned VMs.

The following scripts/commands executed in the VMs sequentially:
* the script to install software
  * (optional) specified varaibles
  * (optional) specified url for sample application tarball
* the commands to remove temporary public key, if required
* the custom commands

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| count | 1 | The count of virtual guests to be provisioned |
| hostname |  | The prefix of hostname of virtual guest |
| domain |  | The domain of virtual guest |
| datacenter |  | The data center where virtual guest is provisoned |
| os_reference_code |  | The operating system code in SoftLayer |
| cores |  | The number of CPU cores |
| memory |  | The memory size in GB |
| disk1 |  | The size of first disk |
| ssh_user | root | The user for ssh to the virtual guest |
| user_public_key_id |  | The public key specified by customer |
| temp_public_key |  | The public key in the key pair temporarily generated for ssh |
| temp_public_key_id |  | The softlayer id of the temporary public key |
| temp_private_key |  | The private key in the key pair temporarily generated for ssh |
| module_script | files/default.sh | The script to install software, used in the module |
| module_script_variable | "" | The variables of the script to install software |
| module_sample_application_url | "" | The url of sample application tarballs used in the script |
| module_custom_commands | sleep 1 | The custom commands |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| public_ip | The public IPs of virtual guests, separated by comma |

#### null_resource

This module is to run scripts/commands in the newly provisioned VM.

The following scripts/commands executed in the VM sequentially:
* the script to install software
  * (optional) specified varaibles
  * (optional) specified url for sample application tarball
* the commands to remove temporary public key, if required
* the custom commands

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| remote_host |  | The virtual guest to run the script |
| ssh_user | root | The user for ssh to the virtual guest |
| temp_public_key |  | The public key in the key pair temporarily generated for ssh |
| temp_private_key |  | The private key in the key pair temporarily generated for ssh |
| remove_temp_private_key | true | The flag whether to remove temporary public key from virtual guest |
| module_script | files/default.sh | The script to install software, used in the module |
| module_script_variable | "" | The variables of the script to install software |
| module_sample_application_url | "" | The url of sample application tarballs used in the script |
| module_custom_commands | sleep 1 | The custom commands |

#### mysql_instance

This module is to provision a MySQL RDS DB in AWS.

The variables expected in the module:

| Variable  | Default  | Description |
| --------- | -------- | ----------- |
| instance_class | db.t2.micro | The flavor of RDS DB instance |
| db_storage_size |  | The storage size of RDS DB instance |
| db_instance_name |  | The name of RDS DB instance |
| db_default_az |  | The availability zone of RDS DB instance |
| db_subnet_group_name |  | The id of subnet group where the instance is created |
| db_security_group_id |  | The id of firewall setup for the instance |
| db_user |  | The user to access the RDS DB instance |
| db_pwd |  | The user password |

The outpt from the module:

| output  | Description |
| ------- | ----------- |
| mysql_address | The FQDN of RDS DB instance |

##### meanstack

TBD

##### LAMP

TBD

##### PHP

TBD
