############################################################
# The variables and data sources used in VPC infra Modules. 
############################################################

variable "REGION" {
	type		= string
	description	= "Cloud Region"
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
		error_message = "The REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao."
	}
}

variable "ZONE" {
	type		= string
	description	= "Cloud Zone"
	validation {
		condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "DOMAIN_NAME" {
	type		= string
	description	= "Private Domain Name"
	nullable = false
	default = ""
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
	description	= "Private SubDomain Name"
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
	description	= "Private SubDomain Name"
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
	description	= "Private SubDomain Name"
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

variable "RESOURCE_GROUP" {
  type        = string
  description = "EXISTING Resource Group for VSIs and Volumes"
  default     = "Default"
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "SSH Keys ID list to access the VSI"
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
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
	default		= "ibm-redhat-8-6-amd64-sap-hana-2"
}

variable "DB-HOSTNAME-1" {
	type		= string
	description = "DB VSI Hostname-1"
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
	description = "DB VSI Hostname-2"
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
	default		= "ibm-redhat-8-6-amd64-sap-hana-2"
}

variable "APP-HOSTNAME-1" {
	type		= string
	description = "APP VSI Hostname-1"
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
	description = "DB VSI Hostname-2"
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

###

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
