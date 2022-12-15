# SAP S/4HANA HA Deployment


## Description
This automation solution is designed for the deployment of  **SAP S/4HANA HA cluster solution** on top of **Red Hat Enterprise Linux 8.x**. The SAP solution will be deployed in an existing IBM Cloud Gen2 VPC, using an existing bastion host with secure remote SSH access.

It contains:
- Terraform scripts for deploying one Power Placement group to include all the 4 VMs involved in this solution.
- Terraform scripts for deploying four VSIs in an EXISTING VPC with Subnet and Security Group configs. The VSIs scope: two for the HANA database cluster instance and two for the SAP application cluster.
- Terraform scripts for deploying and configuring three Application Load Balancers like HANA DB, SAP ASCS/ERS.
- Terraform scripts for deploying and configuring one VPC DNS service used to map the ALB FQDN to the SAP ASCS/ERS and Hana Virtual hostnames.
- Terraform scripts for deploying and configuring seven File shares for VPC.
- Ansible scripts for OS requirements installation and configuration for SAP applications
- Ansible scripts for cluster components installation
- Ansible scripts for SAP application cluster configuration and SAP HANA cluster configuration
- Ansible scripts for HANA installation
- Ansible scripts for HANA DB backup
- Ansible scripts for HANA system replica configuration
- Ansible scripts for ASCS and ERS instances installation
- Ansible scripts for DB load
- Ansible scripts for primary and additional application servers installation

Please note that Ansible is started by Terraform and must be available on the same host.

## Installation media
SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS05** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

SAP S/4HANA installation media used for this deployment is the default one for **SAP S/4HANA 2020** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

SAP Software Provisioning Manager used for this solution is **2.0 SP13** and it's recommended to use the same version or higher.

## VSI Configuration
The VSIs are configured with Red Hat Enterprise Linux 8 for SAP HANA (amd64)  and they have: at least two SSH keys configured to access as root user and the following storage volumes created for DB and SAP APP VSI:

HANA DB VSI Disks:
- 3 x 500 GB disks with 10 IOPS / GB - DATA
- 1 x 10 GB disk - SWAP

SAP APPs VSI Disks:
- 1x 40 GB disk with 10 IOPS / GB - SWAP

File Shares:
- 6 x 20GB file shares - DATA
- 1 x 80GB file shares  -DATA

## IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).

## Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostname, Profile, Image, SSH Keys like so:
```shell
REGION = "eu-de"
# Region for the VSI. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-2"
# Availability zone for VSI. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-2"

DOMAIN_NAME = "example.com"
# The DOMAIN_NAME variable should contain at least one "." as a separator. It is a private domain and it is not reacheable to and from the outside world.
# The DOMAIN_NAME variable could be like a subdomain name. Ex.: staging.example.com
# Domain names can only use letters, numbers, and hyphens.
# Hyphens cannot be used at the beginning or end of the domain name.
# You can't use a domain name that is already in use.
# Domain names are not case sensitive.

ASCS-VIRT-HOSTNAME = "sapascs"
# ASCS Virtual hostname​
# Default =  "sap($your_sap_sid)ascs"

ERS-VIRT-HOSTNAME =  "sapers"
# ERS Virtual Hostname​  
# Default =  "sap($your_sap_sid)ascs"

HANA-VIRT-HOSTNAME = "dbhana"
# Hana Virtual Hostname
# Default = "db($your_hana_sid)hana"

VPC = "ic4sap"
# EXISTING VPC, previously created by the user in the same region as the VSI. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# EXISTING Security group, previously created by the user in the same VPC. The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a", "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]


##########################################################
# File Shares variables:
##########################################################

share_profile = "tier-5iops"
# Enter the IOPs (IOPS per GB) tier for File Share storage. Valid values are 3, 5, and 10.

# File shares sizes:
usrsap-as1      = "20"
usrsap-as2      = "20"
usrsap-sapascs  = "20"
usrsap-sapers   = "20"
usrsap-sapmnt   = "20"
usrsap-sapsys   = "20"
usrsap-trans    = "80"
# Enter Custom File Shares sizes for SAP mounts.

##########################################################
# DB VSI variables:
##########################################################
DB-HOSTNAME-1 = "hanadb-1"
# Hana Cluster VSI1 Hostname.
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Default: DB-HOSTNAME-1 = "hanadb-$your_hana_sid-1"

DB-HOSTNAME-2 = "hanadb-2"
# Hana Cluster VSI2 Hostname.
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Default: DB-HOSTNAME-2 = "hanadb-$your_hana_sid-2"

DB-PROFILE = "mx2-16x128"
# The DB VSI profile. Supported profiles for DB VSI: mx2-16x128. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

DB-IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4"
# OS image for DB VSI. Supported OS images for DB VSIs: ibm-redhat-8-4-amd64-sap-hana-4
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB-IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4" 

##########################################################
# SAP APP VSI variables:
##########################################################
APP-HOSTNAME-1 = "sapapp-1"
# SAP Cluster VSI1 Hostname.
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Default: APP-HOSTNAME-1 = "sapapp-$your_sap_sid-1"

APP-HOSTNAME-2 = "sapapp-2"
# SAP Cluster VSI2 Hostname.
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Default: APP-HOSTNAME-2 = "sapapp-$your_sap_sid-2"

APP-PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP-IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4"
# OS image for SAP APP VSI. Supported OS images for APP VSIs: ibm-redhat-8-4-amd64-sap-hana-4.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP-IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4" 
......
```
Parameter | Description
----------|------------
ibmcloud_api_key | IBM Cloud API key (Sensitive* value).
SSH_KEYS | List of SSH Keys IDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH IDS from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
DOMAIN_NAME | The Domain Name used for DNS and ALB. Duplicates are not allowed. The list with DNS resources can be searched [here](https://cloud.ibm.com/resources). <br />  Sample value:  "example.com"
SHARE PROFILES | IOPS per GB tier for File Share storage. Valid values are 3, 5, and 10. For more info about file share profiles, check [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles). <br/> Default value:  share_profile = "tier-5iops".
SHARE SIZES | Custom File Shares Sizes for SAP mounts. Sample values:  usrsap-sapmnt   = "20" , usrsap-trans    = "80".
[DB/APP]- <br />VIRT-HOSTNAMES | ASCS/ERS/HANA virtual hostnames.  <br /> Default values:  "sap($your_sap_sid)ascs/ers" , "sap($your_sap_sid)ers" , "db($your_hana_sid)hana".
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
[DB/APP]-HOSTNAMES | SAP HANA/APP Cluster VSI Hostnames. Each hostname should be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361). <br> Default values: APP-HOSTNAME-1/2 = "sapapp-$your_sap_sid-1/2" ,  DB-HOSTNAME-1/2 = "hanadb-$your_hana_sid-1/2".
[DB/APP]-PROFILES | The profile used for the HANA/APP VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)
[DB/APP]-IMAGE | The OS image used for the HANA/APP VSI. You must use the Red Hat Enterprise Linux 8 for SAP HANA (amd64) image for all VMs as this image contains  the required SAP and HA subscriptions.  A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)

Edit your SAP system configuration variables that will be passed to the ansible automated deployment:

```shell
hana_sid = "HDB"
# SAP HANA system ID. Should follow the SAP rules for SID naming.
# Obs. This will be used  also as identification number across different HA name resources. Duplicates are not allowed.
# Example: hana_sid = "HDB"

hana_sysno = "00"
# SAP HANA instance number. Should follow the SAP rules for instance number naming.
# Example: hana_sysno = "00"

hana_system_usage = "custom"
# System usage. Default: custom. Suported values: production, test, development, custom
# Example: hana_system_usage = "custom"

hana_components = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: hana_components = "server"

kit_saphana_file = "/storage/HANADB/51055299.ZIP"
# SAP HANA Installation kit path
# Supported SAP HANA versions on Red Hat 8.4 and Suse 15.3: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
# Supported SAP HANA versions on Red Hat 7.6: HANA 2.0 SP 5 Rev 52, kit file: 51054623.ZIP
# Example for Red Hat 7: kit_saphana_file = "/storage/HANADB/51054623.ZIP"
# Example for Red Hat 8 or Suse 15: kit_saphana_file = "/storage/HANADB/51055299.ZIP"

##########################################################
# SAP system configuration
##########################################################

sap_sid = "NWD"
# SAP System ID
# Obs. This will be used  also as identification number across different HA name resources. Duplicates are not allowed.

sap_ascs_instance_number = "00"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: sap_ascs_instance_number = "00"

sap_ers_instance_number = "01"
# The enqueue replication server instance number. Should follow the SAP rules for instance number naming.
# Example: sap_ers_instance_number = "01"

sap_ci_instance_number = "10"
# The primary application server instance number. Should follow the SAP rules for instance number naming.
# Example: sap_ci_instance_number = "10"

sap_aas_instance_number = "20"
# The additional application server instance number. Should follow the SAP rules for instance number naming.
# Example: sap_aas_instance_number = "20"

hdb_concurrent_jobs = "23"
# Number of concurrent jobs used to load and/or extract archives to HANA Host

##########################################################
# SAP S/4HANA APP Kit Paths
##########################################################

kit_sapcar_file = "/storage/S4HANA/SAPCAR_1010-70006178.EXE"
kit_swpm_file = "/storage/S4HANA/SWPM20SP13_1-80003424.SAR"
kit_sapexe_file = "/storage/S4HANA/SAPEXE_100-70005283.SAR"
kit_sapexedb_file = "/storage/S4HANA/SAPEXEDB_100-70005282.SAR"
kit_igsexe_file = "/storage/S4HANA/igsexe_1-70005417.sar"
kit_igshelper_file = "/storage/S4HANA/igshelper_17-10010245.sar"
kit_saphotagent_file = "/storage/S4HANA/SAPHOSTAGENT51_51-20009394.SAR"
kit_hdbclient_file = "/storage/S4HANA/IMDB_CLIENT20_009_28-80002082.SAR"
kit_s4hana_export = "/storage/S4HANA/export"

```
**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
hana_sid | The SAP system ID identifies the SAP HANA system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
hana_sysno | Specifies the instance number of the SAP HANA system| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
hana_system_usage  | System Usage | Default: custom<br> Valid values: production, test, development, custom
hana_components | SAP HANA Components | Default: server<br> Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
kit_saphana_file | Path to SAP HANA ZIP file | As downloaded from SAP Support Portal
sap_sid | The SAP system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
sap_ascs_instance_number | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
sap_ers_instance_number | Technical identifier for internal processes of ERS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
sap_ci_instance_number | Technical identifier for internal processes of PAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
sap_aas_instance_number | Technical identifier for internal processes of AAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
hdb_concurrent_jobs | Number of concurrent jobs used to load and/or extract archives to HANA Host | Default: 23
kit_sapcar_file  | Path to sapcar binary | As downloaded from SAP Support Portal
kit_swpm_file | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
kit_sapexe_file | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal
kit_sapexedb_file | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal
kit_igsexe_file | Path to IGS archive (SAR) | As downloaded from SAP Support Portal
kit_igshelper_file | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal
kit_saphostagent_file | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
kit_hdbclient_file | Path to HANA DB client archive (SAR) | As downloaded from SAP Support Portal
kit_s4hana_export | Path to S/4HANA Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path


**SAP Passwords** 
The passwords for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment. (Sensitive* values).

Parameter | Description | Requirements
----------|-------------|-------------
sap_main_password | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>
hana_main_password | HANA system master password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li><li>Master Password must contain at least one upper-case character</li></ul>
ha_password | HA cluster password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

**Obs***: <br />
- Sensitive - The variable value is not displayed in your tf files details after terrafrorm plan&apply commands.<br />
- The following variables should be the same like the bastion ones: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.

## VPC Configuration

The Security Rules inherited in case that it is used an SAP BASTION deployment:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.


## Files description and structure:
 - `modules` - directory containing the terraform modules
 - `input.auto.tfvars` - contains the variables that will need to be edited by the user to customize the solution
 - `integration.tf` - contains the integration code that brings the SAP variabiles from Terraform to Ansible.
 - `main.tf` - contains the configuration of the VSI for SAP single tier deployment.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (SAP VSI Private IPs, Domain Name)

## Steps to follow:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'ibmcloud_api_key', 'sap_main_password' , 'hana_main_password' and 'ha_password'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'ibmcloud_api_key', 'sap_main_password' , 'hana_main_password' and 'ha_password'.
```

### Related links:

- [See how to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
