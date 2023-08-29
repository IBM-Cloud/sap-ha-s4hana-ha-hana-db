##########################################################
# General VPC variables:
##########################################################

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
# ASCS Virtual Hostname
# Default =  "sap($your_sap_sid)ascs"

ERS_VIRT_HOSTNAME = "sapers"
# ERS Virtual Hostname
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

SUBNET = "alint-de-subnet1"
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a", "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]


##########################################################
# File Shares variables:
##########################################################

SHARE_PROFILE = "dp2"
# Enter the File Share Storage Profile.
# More details on https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile."

# Default File shares sizes:
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
# The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).
# For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) 
# Default value: "mx2-16x128"

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-3"
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

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-3"
# OS image for SAP APP VSI. Supported OS images for APP VSIs: ibm-redhat-8-4-amd64-sap-hana-4.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4" 

##########################################################
# SAP HANA configuration
##########################################################

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

KIT_SAPHANA_FILE = "/storage/HANADB/51056441.ZIP"
# SAP HANA Installation kit path
# Supported SAP HANA versions on Red Hat 8.4, 8.6 and Suse 15.3, 15.4: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
# Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51056441.ZIP"

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "S4A"
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
KIT_SWPM_FILE = "/storage/S4HANA/SWPM20SP15_5-80003424.SAR"
KIT_SAPEXE_FILE = "/storage/S4HANA/SAPEXE_300-80005374.SAR"
KIT_SAPEXEDB_FILE = "/storage/S4HANA/SAPEXEDB_300-80005373.SAR"
KIT_IGSEXE_FILE = "/storage/S4HANA/igsexe_1-70005417.sar"
KIT_IGSHELPER_FILE = "/storage/S4HANA/igshelper_17-10010245.sar"
KIT_SAPHOSTAGENT_FILE = "/storage/S4HANA/SAPHOSTAGENT61_61-80004822.SAR"
KIT_HDBCLIENT_FILE = "/storage/S4HANA/IMDB_CLIENT20_017_22-80002082.SAR"
KIT_S4HANA_EXPORT = "/storage/S4HANA/export"
