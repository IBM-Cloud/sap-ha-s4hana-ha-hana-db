############################################################
# The variables and data sources used in VPC infra Modules. 
############################################################

variable "private_ssh_key" {
	type		= string
	description = "Input id_rsa private key content"
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "IBM Cloud SSH Keys ID list to access the VSIs"
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "BASTION_FLOATING_IP" {
	type		= string
	description = "Input the FLOATING IP from the Bastion Server"
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "EXISTING Resource Group for VPC Resources and File Shares"
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "Cloud Region"
	validation {
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east"], var.REGION )
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE" {
	type		= string
	description	= "Cloud Zone"
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "EXISTING VPC name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "EXISTING Subnet name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "EXISTING Security group name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "DOMAIN_NAME" {
	type		= string
	description	= "Private Domain Name"
	nullable = false
	default = "example.com"
	validation {
		condition     =  length(var.DOMAIN_NAME) > 2  && length (regex("^[a-z]*||^[0-9]*||\\.||\\-", var.DOMAIN_NAME)) > 0  && length (regex("[\\.]", var.DOMAIN_NAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.DOMAIN_NAME)) == 0
		error_message = "The DOMAIN_NAME variable should not be empty and must contain at least one \".\" as a separator and no special chars are allowed."
	}
}

locals {
	ASCS-VIRT-HOSTNAME = "sap${var.sap_sid}ascs"
	ERS-VIRT-HOSTNAME = "sap${var.sap_sid}ers"
	HANA-VIRT-HOSTNAME = "db${var.hana_sid}hana"
}

variable "ASCS-VIRT-HOSTNAME" {
	type		= string
	description	= "ASCS Virtual hostname​"
	nullable = false
	default = "sapascs"
	validation {
		condition     =  length(var.ASCS-VIRT-HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.ASCS-VIRT-HOSTNAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.ASCS-VIRT-HOSTNAME)) == 0
		error_message = "The SUBDOMAIN_NAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT-HOSTNAME-ASCS {
  value = var.ASCS-VIRT-HOSTNAME != "sapascs" ? var.ASCS-VIRT-HOSTNAME : lower ("${local.ASCS-VIRT-HOSTNAME}")
}

variable "ERS-VIRT-HOSTNAME" {
	type		= string
	description	= "ERS Virtual hostname"
	nullable = false
	default = "sapers"
	validation {
		condition     =  length(var.ERS-VIRT-HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.ERS-VIRT-HOSTNAME)) > 0 && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.ERS-VIRT-HOSTNAME)) == 0
		error_message = "The SUBDOMAIN_NAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT-HOSTNAME-ERS {
  value = var.ERS-VIRT-HOSTNAME != "sapers" ? var.ERS-VIRT-HOSTNAME : lower ("${local.ERS-VIRT-HOSTNAME}")
}

variable "HANA-VIRT-HOSTNAME" {
	type		= string
	description	= "HANA Virtual hostname"
	nullable = false
	default = "dbhana"
	validation {
		condition     =  length(var.HANA-VIRT-HOSTNAME) > 2  && length (regex("^[a-z]*||^[0-9]*", var.HANA-VIRT-HOSTNAME)) > 0  && length (regexall("[\\&]|[\\%]|[\\!]|[\\@]|[\\#]|[\\*]|[\\^]", var.HANA-VIRT-HOSTNAME)) == 0
		error_message = "The SUBDOMAIN_NAME variable should not be empty and no special chars are allowed."
	}
}

output VIRT-HOSTNAME-HANA {
  value = var.HANA-VIRT-HOSTNAME != "dbhana" ? var.HANA-VIRT-HOSTNAME : lower ("${local.HANA-VIRT-HOSTNAME}")
}

locals {
	DB-HOSTNAME-1 = "hanadb-${var.hana_sid}-1"
	DB-HOSTNAME-2 = "hanadb-${var.hana_sid}-2"
	APP-HOSTNAME-1 = "sapapp-${var.sap_sid}-1"
	APP-HOSTNAME-2 = "sapapp-${var.sap_sid}-2"
	
}

variable "DB-PROFILE" {
	type		= string
	description = "DB VSI Profile"
	default		= "mx2-16x128"
}

variable "DB-IMAGE" {
	type		= string
	description = "DB VSI OS Image"
	default		= "ibm-redhat-8-4-amd64-sap-hana-4"
}

variable "DB-HOSTNAME-1" {
	type		= string
	description = "DB VSI Hostname-1. \n Obs.: With the default value, the output is dynamically based on <HANASID> like this: \"hanadb-$your_hana_sid-1\""
	default = "hanadb-1"
	validation {
		condition     = length(var.DB-HOSTNAME-1) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB-HOSTNAME-1)) > 0
		error_message = "The DB-HOSTNAME is not valid."
	}
}

output HANA-DB-HOSTNAME-VSI1 {
  value = var.DB-HOSTNAME-1 != "hanadb-1" ? var.DB-HOSTNAME-1 : lower ("${local.DB-HOSTNAME-1}")
}

variable "DB-HOSTNAME-2" {
	type		= string
	description = "DB VSI Hostname-2. \n Obs.: With the default value, the output is dynamically based on <HANASID> like this: \"hanadb-$your_hana_sid-2\""
	default = "hanadb-2"
	nullable = true
	validation {
		condition     = length(var.DB-HOSTNAME-2) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB-HOSTNAME-2)) > 0
		error_message = "The DB-HOSTNAME is not valid."
	}
}

output HANA-DB-HOSTNAME-VSI2 {
  value = var.DB-HOSTNAME-2 != "hanadb-2" ? var.DB-HOSTNAME-2 : lower ("${local.DB-HOSTNAME-2}")
}

variable "APP-PROFILE" {
	type		= string
	description = "VSI Profile"
	default		= "bx2-4x16"
}

variable "APP-IMAGE" {
	type		= string
	description = "VSI OS Image"
	default		= "ibm-redhat-8-4-amd64-sap-hana-4"
}

variable "APP-HOSTNAME-1" {
	type		= string
	description = "APP VSI Hostname-1. \n Obs.: With the default value, the output is dynamically based on <SAPSID> like this: \"sapapp-$your_sap_sid-1\""
	default = "sapapp-1"
	validation {
		condition     = length(var.APP-HOSTNAME-1) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP-HOSTNAME-1)) > 0
		error_message = "The APP-HOSTNAME is not valid."
	}
}

output SAP-APP-HOSTNAME-VSI1 {
  value = var.APP-HOSTNAME-1 != "sapapp-1" ? var.APP-HOSTNAME-1 : lower ("${local.APP-HOSTNAME-1}")
}

variable "APP-HOSTNAME-2" {
	type		= string
	description = "APP VSI Hostname-2. \n Obs.: With the default value, the output is dynamically based on <SAPSID> like this: \"sapapp-$your_sap_sid-2\""
	default = "sapapp-2"
	nullable = true
	validation {
		condition     = length(var.APP-HOSTNAME-2) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP-HOSTNAME-2)) > 0
		error_message = "The APP-HOSTNAME is not valid."
	}
}

output SAP-APP-HOSTNAME-VSI2 {
  value = var.APP-HOSTNAME-2 != "sapapp-2" ? var.APP-HOSTNAME-2 : lower ("${local.APP-HOSTNAME-2}")
}

locals {
  SAP-ALB-ASCS = "sap-alb-ascs"
  SAP-ALB-ERS = "sap-alb-ers"
  DB-ALB-HANA = "db-alb-hana"
}

data "ibm_is_lb" "alb-ascs" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.SAP-ALB-ASCS}-${var.sap_sid}")
}

data "ibm_is_lb" "alb-ers" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.SAP-ALB-ERS}-${var.sap_sid}")
}

data "ibm_is_lb" "alb-hana" {
  depends_on = [module.alb-prereq]
  name    = lower ("${local.DB-ALB-HANA}-${var.hana_sid}")
}

data "ibm_is_instance" "app-vsi-1" {
  depends_on = [module.app-vsi]
  name    =  var.APP-HOSTNAME-1 != "sapapp-1" ? var.APP-HOSTNAME-1 : lower ("${local.APP-HOSTNAME-1}")
}

data "ibm_is_instance" "app-vsi-2" {
  depends_on = [module.app-vsi]
  name    = var.APP-HOSTNAME-2 != "sapapp-2" ? var.APP-HOSTNAME-2 : lower ("${local.APP-HOSTNAME-2}")
}

data "ibm_is_instance" "db-vsi-1" {
  depends_on = [module.db-vsi]
  name    =  var.DB-HOSTNAME-1 != "hanadb-1" ? var.DB-HOSTNAME-1 : lower ("${local.DB-HOSTNAME-1}")
}

data "ibm_is_instance" "db-vsi-2" {
  depends_on = [module.db-vsi]
  name    = var.DB-HOSTNAME-2 != "hanadb-2" ? var.DB-HOSTNAME-2 : lower ("${local.DB-HOSTNAME-2}")
}

############################################################
# The variables and data sources used in File_Shares Module. 
############################################################

data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

variable "share_profile" {
  description = "Enter the IOPs (IOPS per GB) tier for File Share storage. Valid values are 3, 5, and 10."
  type        = string
  default     = "tier-5iops"
}

variable "usrsap-as1" {
  description = "FS Size in GB for usrsap-as1"
  type        = number
  default = 20
}

variable "usrsap-as2" {
  description = "FS Size in GB for usrsap-as2"
  type        = number
  default = 20
}

variable "usrsap-sapascs" {
  description = "FS Size in GB for usrsap-sapascs"
  type        = number
  default = 20
}

variable "usrsap-sapers" {
  description = "FS Size in GB for usrsap-sapers"
  type        = number
  default = 20
}

variable "usrsap-sapmnt" {
  description = "FS Size in GB for usrsap-sapmnt"
  type        = number
  default = 20
}

variable "usrsap-sapsys" {
  description = "FS Size in GB for usrsap-sapsys"
  type        = number
  default = 20
}

variable "usrsap-trans" {
  description = "FS Size in GB for usrsap-trans"
  type        = number
  default = 80
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "hana_sid" {
	type		= string
	description = "hana_sid"
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.hana_sid)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.hana_sid)
		error_message = "The hana_sid is not valid."
	}
}

variable "sap_ascs_instance_number" {
	type		= string
	description = "sap_ascs_instance_number"
	default		= "00"
	validation {
		condition     = var.sap_ascs_instance_number >= 0 && var.sap_ascs_instance_number <=97
		error_message = "The sap_ascs_instance_number is not valid."
	}
}

variable "sap_ers_instance_number" {
	type		= string
	description = "sap_ers_instance_number"
	default		= "01"
	validation {
		condition     = var.sap_ers_instance_number >= 00 && var.sap_ers_instance_number <=99
		error_message = "The sap_ers_instance_number is not valid."
	}
}

variable "sap_ci_instance_number" {
	type		= string
	description = "sap_ci_instance_number"
	default		= "10"
	validation {
		condition     = var.sap_ci_instance_number >= 00 && var.sap_ci_instance_number <=99
		error_message = "The sap_ci_instance_number is not valid."
	}
}

variable "sap_aas_instance_number" {
	type		= string
	description = "sap_aas_instance_number"
	default		= "20"
	validation {
		condition     = var.sap_aas_instance_number >= 00 && var.sap_aas_instance_number <=99
		error_message = "The sap_aas_instance_number is not valid."
	}
}

variable "hana_sysno" {
	type		= string
	description = "hana_sysno"
	default		= "00"
	validation {
		condition     = var.hana_sysno >= 0 && var.hana_sysno <=97
		error_message = "The hana_sysno is not valid."
	}
}

variable "hana_main_password" {
	type		= string
	sensitive = true
	description = "HANADB main password"
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.hana_main_password)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.hana_main_password)) > 0
		error_message = "The hana_main_password is not valid."
	}
}

variable "hana_system_usage" {
	type		= string
	description = "hana_system_usage"
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.hana_system_usage )
		error_message = "The hana_system_usage must be one of: production, test, development, custom."
	}
}

variable "hana_components" {
	type		= string
	description = "hana_components"
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.hana_components )
		error_message = "The hana_components must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "kit_saphana_file" {
	type		= string
	description = "kit_saphana_file"
	default		= "/storage/HANADB/51055299.ZIP"
}

variable "sap_sid" {
	type		= string
	description = "sap_sid"
	default		= "S4A"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.sap_sid)) > 0 && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.sap_sid)
		error_message = "The sap_sid is not valid."
	}
}

variable "sap_main_password" {
	type		= string
	sensitive = true
	description = "SAP main password"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.sap_main_password)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.sap_main_password)) > 0
		error_message = "The sap_main_password is not valid."
	}
}

variable "ha_password" {
	type		= string
	sensitive = true
	description = "HA cluster password"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.ha_password)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.ha_password)) > 0
		error_message = "The ha_password is not valid."
	}
}

variable "hdb_concurrent_jobs" {
	type		= string
	description = "hdb_concurrent_jobs"
	default		= "23"
	validation {
		condition     = var.hdb_concurrent_jobs >= 1 && var.hdb_concurrent_jobs <=25
		error_message = "The hdb_concurrent_jobs is not valid."
	}
}

variable "kit_sapcar_file" {
	type		= string
	description = "kit_sapcar_file"
	default		= "/storage/S4HANA/SAPCAR_1010-70006178.EXE"
}

variable "kit_swpm_file" {
	type		= string
	description = "kit_swpm_file"
	default		= "/storage/S4HANA/SWPM20SP13_1-80003424.SAR"
}

variable "kit_sapexe_file" {
	type		= string
	description = "kit_sapexe_file"
	default		= "/storage/S4HANA/SAPEXE_100-70005283.SAR"
}

variable "kit_sapexedb_file" {
	type		= string
	description = "kit_sapexedb_file"
	default		= "/storage/S4HANA/SAPEXEDB_100-70005282.SAR"
}

variable "kit_igsexe_file" {
	type		= string
	description = "kit_igsexe_file"
	default		= "/storage/S4HANA/igsexe_1-70005417.sar"
}

variable "kit_igshelper_file" {
	type		= string
	description = "kit_igshelper_file"
	default		= "/storage/S4HANA/igshelper_17-10010245.sar"
}

variable "kit_saphotagent_file" {
	type		= string
	description = "kit_saphotagent_file"
	default		= "/storage/S4HANA/SAPHOSTAGENT51_51-20009394.SAR"
}

variable "kit_hdbclient_file" {
	type		= string
	description = "kit_hdbclient_file"
	default		= "/storage/S4HANA/IMDB_CLIENT20_009_28-80002082.SAR"
}

variable "kit_s4hana_export" {
	type		= string
	description = "kit_s4hana_export"
	default		= "/storage/S4HANA/export"
}