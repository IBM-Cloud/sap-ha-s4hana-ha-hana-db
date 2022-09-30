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

locals {
  replica_zone_empty_check            = var.enable_file_share == true ? (var.replica_zone == "" ? false : true) : true
  replica_zone_empty_check_intimation = "replica zone can not be empty when enable_file_share is false"
  replica_zone_empty                  = regex("^${local.replica_zone_empty_check_intimation}$", (local.replica_zone_empty_check ? local.replica_zone_empty_check_intimation : ""))
}

locals {
  process_replica_zone = var.replica_zone == "" ? var.ZONE : var.replica_zone
}

locals {
  replica_region_check = var.replica_zone == "" ? true : (split("-", local.process_replica_zone)[0] == split("-", var.ZONE)[0] ? ((split("-", local.process_replica_zone)[1] == split("-", var.ZONE)[1]) ? true : false) : false)
  region_intimation    = "replica zone is not in the same region"
  region_check         = regex("^${local.region_intimation}$", (local.replica_region_check ? local.region_intimation : ""))
}

locals {
  replica_zone_check = var.replica_zone == "" || (local.replica_region_check == false) ? true : (split("-", local.process_replica_zone)[2] == split("-", var.ZONE)[2] ? false : true)
  zone_intimation    = "replica zone is in the same zone"
  zone_check         = regex("^${local.zone_intimation}$", (local.replica_zone_check ? local.zone_intimation : (local.replica_zone_check ? local.zone_intimation : "")))
}

variable "replica_zone" {
  description = "Enter the zone the replica for the File Share storage will be created e.g. us-south-1, us-east-1, etc."
  type        = string
  default     = ""
  validation {
    condition     = var.replica_zone == "" ? true : contains(["1", "2", "3"], split("-", var.replica_zone)[2])
    error_message = "The specified replica_zone is out of applicable zones for this region."
  }
}

variable "replication_cron_spec" {
  description = "Enter the file share replication schedule in Linux crontab format."
  type        = string
  default     = "00 08 * * *"
}
