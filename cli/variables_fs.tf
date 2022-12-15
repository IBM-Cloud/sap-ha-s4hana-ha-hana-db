############################################################
# The variables and data sources used in File_Share Module. 
############################################################

data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

variable "usrsap-as1" {
  description = "Resource usrsap-as1"
  type        = number
  default = 20
}

variable "usrsap-as2" {
  description = "Resource usrsap-as2"
  type        = number
  default = 20
}

variable "usrsap-sapascs" {
  description = "Resource usrsap-sapascs"
  type        = number
  default = 20
}

variable "usrsap-sapers" {
  description = "Resource usrsap-sapers"
  type        = number
  default = 20
}

variable "usrsap-sapmnt" {
  description = "Resource usrsap-sapmnt"
  type        = number
  default = 20
}

variable "usrsap-sapsys" {
  description = "Resource usrsap-sapsys"
  type        = number
  default = 20
}

variable "usrsap-trans" {
  description = "Resource usrsap-trans"
  type        = number
  default = 80
}

variable "enable_file_share" {
  description = "This creates File Share storage for the App Tier to support stateful use case. Select true or false."
  type        = bool
  default     = false
}

variable "share_size" {
  description = "File Share storage size in GB. Value should be in between 10 and 32000."
  type        = number
  default     = 20
}

variable "share_profile" {
  description = "Enter the IOPs (IOPS per GB) tier for File Share storage. Valid values are 3, 5, and 10."
  type        = string
  default     = "tier-5iops"
}
