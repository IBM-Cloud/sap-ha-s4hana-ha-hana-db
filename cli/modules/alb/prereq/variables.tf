variable "ZONE" {
    type = string
    description = "Cloud Zone"
}

variable "VPC" {
    type = string
    description = "VPC name"
}

variable "SUBNET" {
    type = string
    description = "Subnet name"
}

variable "SECURITY_GROUP" {
    type = string
    description = "Security group name"
}

variable "RESOURCE_GROUP" {
    type = string
    description = "Resource Group"
}

data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_is_security_group" "securitygroup" {
  name		= var.SECURITY_GROUP
}

data "ibm_is_subnet" "subnet" {
  name		= var.SUBNET
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

variable "SAP_SID" {
    type = string
    description = "SAP SID"
}

#ascsno
variable "SAP_ASCS" {
    type = string
    description = "SAP_ASCS"
}

#ersno
variable "SAP_ERSNO" {
    type = string
    description = "SAP_ERSNO"
}

#hanano
variable "HANA_SYSNO" {
    type = string
    description = "HANA_SYSNO"
}


variable "SAP_ALB_NAME" {
    type = string
    description = "ALB NAME"
}

variable "SAP_ALB_DELAY" {
    type = string
    description = "ALB Delay"
}