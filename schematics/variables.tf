############################################################
# The variables and data sources used in VPC infra Modules. 
############################################################

variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "Input id_rsa private key content (Sensitive* value)."
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "BASTION_FLOATING_IP" {
	type		= string
	description = "Input the FLOATING IP from the Bastion Server."
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for VSIs and Volumes resources. Default value: \"Default\". The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups."
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy the solution. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Review supported locations in IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
	validation {
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east"], var.REGION )
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE" {
	type		= string
	description	= "The cloud zone where to deploy the solution."
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "DOMAIN_NAME" {
	type		= string
	description	= "The Domain Name used for DNS and ALB. Duplicates are not allowed. The list with DNS resources can be searched here: https://cloud.ibm.com/resources."
	nullable = false
	default = "example.com"
	validation {
		condition     =  length(var.DOMAIN_NAME) > 2  && length (regex("^[a-z]*||^[0-9]*||\\.||\\-", var.DOMAIN_NAME)) > 0  && length (regex("[\\.]", var.DOMAIN_NAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.DOMAIN_NAME)) == 0
		error_message = "The DOMAIN_NAME variable should not be empty and must contain at least one \".\" as a separator and no special chars are allowed."
	}
}

locals {
	ASCS_VIRT_HOSTNAME = "sap${var.SAP_SID}ascs"
	ERS_VIRT_HOSTNAME = "sap${var.SAP_SID}ers"
	HANA_VIRT_HOSTNAME = "db${var.HANA_SID}hana"
}

variable "ASCS_VIRT_HOSTNAME" {
	type		= string
	description	= "ASCS Virtual hostname."
	nullable = false
	default = "sapascs"
	validation {
		condition     =  length(var.ASCS_VIRT_HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.ASCS_VIRT_HOSTNAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.ASCS_VIRT_HOSTNAME)) == 0
		error_message = "The SUBDOMAIN_NAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT-HOSTNAME-ASCS {
  value = var.ASCS_VIRT_HOSTNAME != "sapascs" ? var.ASCS_VIRT_HOSTNAME : lower ("${local.ASCS_VIRT_HOSTNAME}")
}

variable "ERS_VIRT_HOSTNAME" {
	type		= string
	description	= "ERS Virtual hostname."
	nullable = false
	default = "sapers"
	validation {
		condition     =  length(var.ERS_VIRT_HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.ERS_VIRT_HOSTNAME)) > 0 && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.ERS_VIRT_HOSTNAME)) == 0
		error_message = "The SUBDOMAIN_NAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT-HOSTNAME-ERS {
  value = var.ERS_VIRT_HOSTNAME != "sapers" ? var.ERS_VIRT_HOSTNAME : lower ("${local.ERS_VIRT_HOSTNAME}")
}

variable "HANA_VIRT_HOSTNAME" {
	type		= string
	description	= "HANA Virtual hostname."
	nullable = false
	default = "dbhana"
	validation {
		condition     =  length(var.HANA_VIRT_HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.HANA_VIRT_HOSTNAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.HANA_VIRT_HOSTNAME)) == 0
		error_message = "The SUBDOMAIN_NAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT-HOSTNAME-HANA {
  value = var.HANA_VIRT_HOSTNAME != "dbhana" ? var.HANA_VIRT_HOSTNAME : lower ("${local.HANA_VIRT_HOSTNAME}")
}

locals {
	DB_HOSTNAME_1 = "hanadb-${var.HANA_SID}-1"
	DB_HOSTNAME_2 = "hanadb-${var.HANA_SID}-2"
	APP_HOSTNAME_1 = "sapapp-${var.SAP_SID}-1"
	APP_HOSTNAME_2 = "sapapp-${var.SAP_SID}-2"
	
}

variable "DB_PROFILE" {
	type		= string
	description = "DB VSI Profile. The certified profiles for SAP HANA in IBM VPC: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc"
	default		= "mx2-16x128"
	validation {
		condition     = contains(keys(jsondecode(file("files/hana_volume_layout.json")).profiles), "${var.DB_PROFILE}")
		error_message = "The chosen storage PROFILE for HANA VSI \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
	}
}

variable "DB_IMAGE" {
	type		= string
	description = "The OS image used for the HANA/APP VSI. You must use the Red Hat Enterprise Linux 8 for SAP HANA (amd64) image for all VMs as this image contains the required SAP and HA subscriptions. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-3"
}

variable "DB_HOSTNAME_1" {
	type		= string
	description = "SAP HANA Cluster VSI Hostnames - DB VSI Hostname-1. \n Obs: With the default value, the output is dynamically based on <HANASID>."
	default = "hanadb-1"
	validation {
		condition     = length(var.DB_HOSTNAME_1) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME_1)) > 0
		error_message = "The DB-HOSTNAME is not valid."
	}
}

output HANA-DB-HOSTNAME-VSI1 {
  value = var.DB_HOSTNAME_1 != "hanadb-1" ? var.DB_HOSTNAME_1 : lower ("${local.DB_HOSTNAME_1}")
}

variable "DB_HOSTNAME_2" {
	type		= string
	description = "SAP HANA Cluster VSI Hostnames - DB VSI Hostname-2. \n Obs: With the default value, the output is dynamically based on <HANASID>."
	default = "hanadb-2"
	nullable = true
	validation {
		condition     = length(var.DB_HOSTNAME_2) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME_2)) > 0
		error_message = "The DB-HOSTNAME is not valid."
	}
}

output HANA-DB-HOSTNAME-VSI2 {
  value = var.DB_HOSTNAME_2 != "hanadb-2" ? var.DB_HOSTNAME_2 : lower ("${local.DB_HOSTNAME_2}")
}

variable "APP_PROFILE" {
	type		= string
	description = "The profile used for the APP VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. For more information, check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
	default		= "bx2-4x16"
}

variable "APP_IMAGE" {
	type		= string
	description = "The OS image used for the APP VSI. You must use the Red Hat Enterprise Linux 8 for SAP HANA (amd64) image for all VMs as this image contains the required SAP and HA subscriptions. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-3"
}

variable "APP_HOSTNAME_1" {
	type		= string
	description = "SAP APP Cluster VSI Hostnames - APP VSI Hostname-1. \n Obs: With the default value, the output is dynamically based on <SAPSID>."
	default = "sapapp-1"
	validation {
		condition     = length(var.APP_HOSTNAME_1) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME_1)) > 0
		error_message = "The APP-HOSTNAME is not valid."
	}
}

output SAP-APP-HOSTNAME-VSI1 {
  value = var.APP_HOSTNAME_1 != "sapapp-1" ? var.APP_HOSTNAME_1 : lower ("${local.APP_HOSTNAME_1}")
}

variable "APP_HOSTNAME_2" {
	type		= string
	description = "SAP APP Cluster VSI Hostnames - APP VSI Hostname-2. \n Obs: With the default value, the output is dynamically based on <SAPSID>."
	default = "sapapp-2"
	nullable = true
	validation {
		condition     = length(var.APP_HOSTNAME_2) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME_2)) > 0
		error_message = "The APP-HOSTNAME is not valid."
	}
}

output SAP-APP-HOSTNAME-VSI2 {
  value = var.APP_HOSTNAME_2 != "sapapp-2" ? var.APP_HOSTNAME_2 : lower ("${local.APP_HOSTNAME_2}")
}

locals {
  SAP-ALB-ASCS = "sap-alb-ascs"
  SAP-ALB-ERS = "sap-alb-ers"
  DB-ALB-HANA = "db-alb-hana"
}

data "ibm_is_lb" "alb-ascs" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.SAP-ALB-ASCS}-${var.SAP_SID}")
}

data "ibm_is_lb" "alb-ers" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.SAP-ALB-ERS}-${var.SAP_SID}")
}

data "ibm_is_lb" "alb-hana" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.DB-ALB-HANA}-${var.HANA_SID}")
}

data "ibm_is_instance" "app-vsi-1" {
  depends_on = [module.app-vsi]
  name    =  var.APP_HOSTNAME_1 != "sapapp-1" ? var.APP_HOSTNAME_1 : lower ("${local.APP_HOSTNAME_1}")
}

data "ibm_is_instance" "app-vsi-2" {
  depends_on = [module.app-vsi]
  name    = var.APP_HOSTNAME_2 != "sapapp-2" ? var.APP_HOSTNAME_2 : lower ("${local.APP_HOSTNAME_2}")
}

data "ibm_is_instance" "db-vsi-1" {
  depends_on = [module.db-vsi]
  name    =  var.DB_HOSTNAME_1 != "hanadb-1" ? var.DB_HOSTNAME_1 : lower ("${local.DB_HOSTNAME_1}")
}

data "ibm_is_instance" "db-vsi-2" {
  depends_on = [module.db-vsi]
  name    = var.DB_HOSTNAME_2 != "hanadb-2" ? var.DB_HOSTNAME_2 : lower ("${local.DB_HOSTNAME_2}")
}

############################################################
# The variables and data sources used in File_Share Module. 
############################################################

data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

variable "SHARE_PROFILE" {
  description = "The File Share Profile Storage. For more details see: https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile."
  type        = string
  default     = "dp2"
}

variable "USRSAP_AS1" {
  description = "File Share Size in GB for USRSAP_AS1"
  type        = number
  default = 20
}

variable "USRSAP_AS2" {
  description = "File Share Size in GB for USRSAP_AS2"
  type        = number
  default = 20
}

variable "USRSAP_SAPASCS" {
  description = "File Share Size in GB for USRSAP_SAPASCS"
  type        = number
  default = 20
}

variable "USRSAP_SAPERS" {
  description = "File Share Size in GB for USRSAP_SAPERS"
  type        = number
  default = 20
}

variable "USRSAP_SAPMNT" {
  description = "File Share Size in GB for USRSAP_SAPMNT"
  type        = number
  default = 20
}

variable "USRSAP_SAPSYS" {
  description = "File Share Size in GB for USRSAP_SAPSYS"
  type        = number
  default = 20
}

variable "USRSAP_TRANS" {
  description = "File Share Size in GB for USRSAP_TRANS"
  type        = number
  default = 80
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "HANA_SID" {
	type		= string
	description = "The SAP system ID identifies the SAP HANA system."
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_SID)
		error_message = "The HANA_SID is not valid."
	}
}

variable "SAP_ASCS_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of ASCS."
	default		= "00"
	validation {
		condition     = var.SAP_ASCS_INSTANCE_NUMBER >= 0 && var.SAP_ASCS_INSTANCE_NUMBER <=97
		error_message = "The SAP_ASCS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_ERS_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of ERS."
	default		= "01"
	validation {
		condition     = var.SAP_ERS_INSTANCE_NUMBER >= 00 && var.SAP_ERS_INSTANCE_NUMBER <=99
		error_message = "The SAP_ERS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of PAS."
	default		= "10"
	validation {
		condition     = var.SAP_CI_INSTANCE_NUMBER >= 00 && var.SAP_CI_INSTANCE_NUMBER <=99
		error_message = "The SAP_CI_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_AAS_INSTANCE_NUMBER" {
	type		= string
	description = "Technical identifier for internal processes of AAS."
	default		= "20"
	validation {
		condition     = var.SAP_AAS_INSTANCE_NUMBER >= 00 && var.SAP_AAS_INSTANCE_NUMBER <=99
		error_message = "The SAP_AAS_INSTANCE_NUMBER is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "Specifies the instance number of the SAP HANA system."
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation."
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.HANA_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.HANA_MAIN_PASSWORD)) > 0
		error_message = "The HANA_MAIN_PASSWORD is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "System Usage. Default: \"custom\". Valid values: \"production\", \"test\", \"development\", \"custom\"."
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message = "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "SAP HANA Components. Default: \"server\". Valid values: \"all\", \"client\", \"es\", \"ets\", \"lcapps\", \"server\", \"smartda\", \"streaming\", \"rdsync\", \"xs\", \"studio\", \"afl\", \"sca\", \"sop\", \"eml\", \"rme\", \"rtl\", \"trp\"."
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "Path to SAP HANA ZIP file, as downloaded from SAP Support Portal."
	default		= "/storage/HANADB/51056441.ZIP"
}

variable "SAP_SID" {
	type		= string
	description = "The SAP system ID identifies the entire SAP system."
	default		= "S4A"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.SAP_SID)) > 0 && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.SAP_SID)
		error_message = "The SAP_SID is not valid."
	}
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation."
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.SAP_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid."
	}
}

variable "HA_PASSWORD" {
	type		= string
	sensitive = true
	description = "HA cluster password."
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.HA_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.HA_PASSWORD)) > 0
		error_message = "The HA_PASSWORD is not valid."
	}
}

variable "HDB_CONCURRENT_JOBS" {
	type		= string
	description = "Number of concurrent jobs used to load and/or extract archives to HANA Host."
	default		= "23"
	validation {
		condition     = var.HDB_CONCURRENT_JOBS >= 1 && var.HDB_CONCURRENT_JOBS <=25
		error_message = "The HDB_CONCURRENT_JOBS is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary, as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SAPCAR_1010-70006178.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SWPM20SP15_5-80003424.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "Path to SAP Kernel OS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SAPEXE_300-80005374.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "Path to SAP Kernel DB archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SAPEXEDB_300-80005373.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "Path to IGS archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/igsexe_1-70005417.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "Path to IGS Helper archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/SAPHOSTAGENT61_61-80004822.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "Path to HANA DB client archive (SAR), as downloaded from SAP Support Portal."
	default		= "/storage/S4HANA/IMDB_CLIENT20_017_22-80002082.SAR"
}

variable "KIT_S4HANA_EXPORT" {
	type		= string
	description = "Path to S/4HANA Installation Export dir. The archives downloaded from SAP Support Portal should be present in this path."
	default		= "/storage/S4HANA/export"
}
