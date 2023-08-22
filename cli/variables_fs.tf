############################################################
# The variables and data sources used in File_Share Module. 
############################################################

data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

variable "USRSAP_AS1" {
  description = "Resource USRSAP-AS1"
  type        = number
  default = 20
}

variable "USRSAP_AS2" {
  description = "Resource USRSAP-AS2"
  type        = number
  default = 20
}

variable "USRSAP_SAPASCS" {
  description = "Resource USRSAP-SAPASCS"
  type        = number
  default = 20
}

variable "USRSAP_SAPERS" {
  description = "Resource USRSAP-SAPERS"
  type        = number
  default = 20
}

variable "USRSAP_SAPMNT" {
  description = "Resource USRSAP-SAPMNT"
  type        = number
  default = 20
}

variable "USRSAP_SAPSYS" {
  description = "Resource USRSAP-SAPSYS"
  type        = number
  default = 20
}

variable "USRSAP_TRANS" {
  description = "Resource USRSAP-TRANS"
  type        = number
  default = 80
}

variable "SHARE_PROFILE" {
  description = "The File Share profile Storage."
  type        = string
  default     = "dp2"
}