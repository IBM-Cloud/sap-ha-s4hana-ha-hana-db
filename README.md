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
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Last updated 2022-01-28

Note: LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, excepting **`vx2d-44x616`** and **`vx2d-88x1232`** profiles, where **`/hana/data`** and **`/hana/shared`** won't be manged by LVM, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Last updated 2022-01-28 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations#hana-iaas-mx2-16x128-32x256-configure) - Last updated 2022-05-19

For example, in case of deploying a HANA VM, using the default value for VSI profile `mx2-16x128`, the automation will execute the following storage setup:  
- 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
  - the volume group will contain the following logical volumes (created with three stripes):
    - `<sid>_hana_data_lv` - size 988 GB
    - `<sid>_hana_log_lv` - size 256 GB
    - `<sid>_hana_shared` - size 256 GB
- 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
- 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

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

ASCS_VIRT_HOSTNAME = "sapascs"
# ASCS Virtual hostname​
# Default =  "sap($your_sap_sid)ascs"

ERS_VIRT_HOSTNAME =  "sapers"
# ERS Virtual Hostname​  
# Default =  "sap($your_sap_sid)ascs"

HANA_VIRT_HOSTNAME = "dbhana"
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

SHARE_PROFILE = "tier-5iops"
# Enter the IOPs (IOPS per GB) tier for File Share storage. Valid values are 3, 5, and 10.

# File shares sizes:
USRSAP_AS1      = "20"
USRSAP_AS2      = "20"
USRSAP_SAPASCS  = "20"
USRSAP_SAPERS   = "20"
USRSAP_SAPMNT   = "20"
USRSAP_SAPSYS   = "20"
USRSAP_TRANS    = "80"
# Enter Custom File Shares sizes for SAP mounts.

##########################################################
# DB VSI variables:
##########################################################
DB_HOSTNAME_1 = "hanadb-1"
# Hana Cluster VSI1 Hostname.
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Default: DB_HOSTNAME_1 = "hanadb-$your_hana_sid-1"

DB_HOSTNAME_2 = "hanadb-2"
# Hana Cluster VSI2 Hostname.
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Default: DB_HOSTNAME_2 = "hanadb-$your_hana_sid-2"

DB_PROFILE = "mx2-16x128"
# The DB VSI profile. Supported profiles for DB VSI: mx2-16x128. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-2"
# OS image for DB VSI. Supported OS images for DB VSIs: ibm-redhat-8-4-amd64-sap-hana-4
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4" 

##########################################################
# SAP APP VSI variables:
##########################################################
APP_HOSTNAME_1 = "sapapp-1"
# SAP Cluster VSI1 Hostname.
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Default: APP_HOSTNAME_1 = "sapapp-$your_sap_sid-1"

APP_HOSTNAME_2 = "sapapp-2"
# SAP Cluster VSI2 Hostname.
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Default: APP_HOSTNAME_2 = "sapapp-$your_sap_sid-2"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-2"
# OS image for SAP APP VSI. Supported OS images for APP VSIs: ibm-redhat-8-4-amd64-sap-hana-4.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4" 
......
```
Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
SSH_KEYS | List of SSH Keys IDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH IDS from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
DOMAIN_NAME | The Domain Name used for DNS and ALB. Duplicates are not allowed. The list with DNS resources can be searched [here](https://cloud.ibm.com/resources). <br />  Sample value:  "example.com"
SHARE PROFILES | IOPS per GB tier for File Share storage. Valid values are 3, 5, and 10. For more info about file share profiles, check [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles). <br/> Default value:  SHARE_PROFILE = "tier-5iops".
SHARE SIZES | Custom File Shares Sizes for SAP mounts. Sample values:  USRSAP_SAPMNT   = "20" , USRSAP_TRANS    = "80".
[DB/APP]- <br />VIRT-HOSTNAMES | ASCS/ERS/HANA virtual hostnames.  <br /> Default values:  "sap($your_sap_sid)ascs/ers" , "sap($your_sap_sid)ers" , "db($your_hana_sid)hana".
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
[DB/APP]-HOSTNAMES | SAP HANA/APP Cluster VSI Hostnames. Each hostname should be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361). <br> Default values: APP_HOSTNAME_1/2 = "sapapp-$your_sap_sid-1/2" ,  DB_HOSTNAME_1/2 = "hanadb-$your_hana_sid-1/2".
[DB/APP]-PROFILES | The profile used for the HANA/APP VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)
[DB/APP]-IMAGE | The OS image used for the HANA/APP VSI. You must use the Red Hat Enterprise Linux 8 for SAP HANA (amd64) image for all VMs as this image contains  the required SAP and HA subscriptions.  A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)

Edit your SAP system configuration variables that will be passed to the ansible automated deployment:

```shell
HANA_SID = "HDB"
# SAP HANA system ID. Should follow the SAP rules for SID naming.
# Obs. This will be used  also as identification number across different HA name resources. Duplicates are not allowed.
# Example: HANA_SID = "HDB"

HANA_SYSNO = "00"
# SAP HANA instance number. Should follow the SAP rules for instance number naming.
# Example: HANA_SYSNO = "00"

HANA_SYSTEM_USAGE = "custom"
# System usage. Default: custom. Suported values: production, test, development, custom
# Example: HANA_SYSTEM_USAGE = "custom"

HANA_COMPONENTS = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: HANA_COMPONENTS = "server"

KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"
# SAP HANA Installation kit path
# Supported SAP HANA versions on Red Hat 8.4, 8.6 and Suse 15.3, 15.4: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
# Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWD"
# SAP System ID
# Obs. This will be used  also as identification number across different HA name resources. Duplicates are not allowed.

SAP_ASCS_INSTANCE_NUMBER = "00"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "00"

SAP_ERS_INSTANCE_NUMBER = "01"
# The enqueue replication server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ERS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "10"
# The primary application server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "10"

SAP_AAS_INSTANCE_NUMBER = "20"
# The additional application server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_AAS_INSTANCE_NUMBER = "20"

HDB_CONCURRENT_JOBS = "23"
# Number of concurrent jobs used to load and/or extract archives to HANA Host

##########################################################
# SAP S/4HANA APP Kit Paths
##########################################################

KIT_SAPCAR_FILE = "/storage/S4HANA/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE = "/storage/S4HANA/SWPM20SP13_1-80003424.SAR"
KIT_SAPEXE_FILE = "/storage/S4HANA/SAPEXE_100-70005283.SAR"
KIT_SAPEXEDB_FILE = "/storage/S4HANA/SAPEXEDB_100-70005282.SAR"
KIT_IGSEXE_FILE = "/storage/S4HANA/igsexe_1-70005417.sar"
KIT_IGSHELPER_FILE = "/storage/S4HANA/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/S4HANA/SAPHOSTAGENT51_51-20009394.SAR"
KIT_HDBCLIENT_FILE = "/storage/S4HANA/IMDB_CLIENT20_009_28-80002082.SAR"
KIT_S4HANA_EXPORT = "/storage/S4HANA/export"

```
**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
HANA_SID | The SAP system ID identifies the SAP HANA system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
HANA_SYSNO | Specifies the instance number of the SAP HANA system| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HANA_SYSTEM_USAGE  | System Usage | Default: custom<br> Valid values: production, test, development, custom
HANA_COMPONENTS | SAP HANA Components | Default: server<br> Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file | As downloaded from SAP Support Portal
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
SAP_ASCS_INSTANCE_NUMBER | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_ERS_INSTANCE_NUMBER | Technical identifier for internal processes of ERS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_CI_INSTANCE_NUMBER | Technical identifier for internal processes of PAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_AAS_INSTANCE_NUMBER | Technical identifier for internal processes of AAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HDB_CONCURRENT_JOBS | Number of concurrent jobs used to load and/or extract archives to HANA Host | Default: 23
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSEXE_FILE | Path to IGS archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal
kit_saphostagent_file | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
KIT_HDBCLIENT_FILE | Path to HANA DB client archive (SAR) | As downloaded from SAP Support Portal
KIT_S4HANA_EXPORT | Path to S/4HANA Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path


**SAP Passwords** 
The passwords for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment. (Sensitive* values).

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>
HANA_MAIN_PASSWORD | HANA system master password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li><li>Master Password must contain at least one upper-case character</li></ul>
HA_PASSWORD | HA cluster password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

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
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD' , 'HANA_MAIN_PASSWORD' and 'HA_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD' , 'HANA_MAIN_PASSWORD' and 'HA_PASSWORD'.
```

### Related links:

- [See how to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
