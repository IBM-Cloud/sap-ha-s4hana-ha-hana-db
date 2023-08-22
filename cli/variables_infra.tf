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
	ASCS_VIRT_HOSTNAME = "sap${var.SAP_SID}ascs"
	ERS_VIRT_HOSTNAME = "sap${var.SAP_SID}ers"
	HANA_VIRT_HOSTNAME = "db${var.HANA_SID}hana"
}

variable "ASCS_VIRT_HOSTNAME" {
	type		= string
	description	= "Private SubDomain Name"
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
	description	= "Private SubDomain Name"
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
	description	= "Private SubDomain Name"
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
	description = "DB VSI OS Image"
	default		= "ibm-redhat-8-6-amd64-sap-hana-2"
	validation {
		condition     = length(regexall("^(ibm-redhat-8-6-amd64-sap-hana|ibm-redhat-8-4-amd64-sap-hana|ibm-sles-15-4-amd64-sap-hana|ibm-sles-15-3-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
		error_message = "The OS SAP DB_IMAGE must be one of  \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-redhat-8-6-amd64-sap-hana-x\" or \"ibm-redhat-8-4-amd64-sap-hana-x\"."
 	}
}

variable "DB_HOSTNAME_1" {
	type		= string
	description = "DB VSI Hostname-1"
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
	description = "DB VSI Hostname-2"
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
	description = "VSI Profile"
	default		= "bx2-4x16"
}

variable "APP_IMAGE" {
	type		= string
	description = "VSI OS Image"
	default		= "ibm-redhat-8-6-amd64-sap-hana-2"
}

variable "APP_HOSTNAME_1" {
	type		= string
	description = "APP VSI Hostname-1"
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
	description = "DB VSI Hostname-2"
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

###

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
