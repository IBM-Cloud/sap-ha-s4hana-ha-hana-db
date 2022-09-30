/**
#################################################################################################################
*                           Variable Section for the Bastion Module.
*                                 Start Here of the Variable Section 
#################################################################################################################
*/
variable "SAP_SID" {
    type = string
    description = "SAP SID"
}

/**
* Name: resource_group_name
* Type: String
*/
variable "resource_group_name" {
  description = "Resource Group Name is used to separate the resources in a group."
  type        = string
}

/**
* Name: api_key
* Type: String
* Desc: Please enter the IBM Cloud API key
*/
variable "api_key" {
  description = "Please enter the IBM Cloud API key."
  type        = string
}

/**
* Name: region
* Type: String
* Desc: Region to be used for resources creation
*/
variable "region" {
  description = "Please enter a region from the following available region and zones mapping: \nus-south\nus-east\neu-gb\neu-de\njp-tok\nau-syd\njp-osa\nbr-sao\nca-tor"
  type        = string
}

/**
* Name: prefix
* Type: String
* Desc: This is the prefix text that will be prepended in every resource name created by this script.
**/
variable "prefix" {
  description = "Prefix for all the resources."
  type        = string
}

/**
* Name: vpc_id
* Type: String
* Desc: This is the vpc ID which will be used for bastion module. We are passing this vpc_id from main.tf
**/
variable "vpc_id" {
  description = "Required parameter vpc_id"
  type        = string
}

/**
* Name: zone
* Desc: Availability Zone where bastion resource will be created
* Type: String
**/
variable "zone" {
  description = "Availability Zone where bastion resource will be created"
  type        = string
}

/**
* Name: share_size
* Type: String
* Desc: Specify the file share size. The value should be between 10 GB to 32000 GB's
*   Min Value: 10 GB
*   Max Value: 32000 GB
**/
variable "share_size" {
  description = "Specify the file share size. The value should be between 10 GB to 32000 GB's"
  type        = number
}

/**
* Name: share_profile
* Type: String
* Desc: Enter the share profile value. The value should be tier-3iops, tier-5iops and tier-10iops
*              Possible Values are tier-3iops, tier-5iops and tier-10iops
**/
variable "share_profile" {
  description = "Enter the share profile value. The value should be tier-3iops, tier-5iops and tier-10iops"
  type        = string
}

/**
* Name: enable_file_share
* Type: Boolean
* Desc: Enter true or false. This variable will determine whether to create the file share or not.
**/
variable "enable_file_share" {
  description = "Enter true or false. This variable will determine whether to create the file share or not."
  type        = bool
}

/**
* Name: replica_zone
* Desc: Availability Zone where replica file share resource will be created
* Type: String
**/
variable "replica_zone" {
  description = "Availability Zone where replica file share resource will be created"
  type        = string
}

/**
# Name: replication_cron_spec
# Type: String
# Desc: Enter the file share replication schedule in Linux crontab format.
# You can choose how often you want to sync changes from the source share to the replica. 
# You can specify replication using a cron-spec (https://en.wikipedia.org/wiki/Cron)
# Replications must be scheduled at least one hour apart. 
# If both "day of month" (field 3) and "day of week" (field 5) are restricted (not contain "*"),then one or both must match the current day.
#
# ┌─────minute (0 - 59)
# │ ┌─────hour (0 - 23)
# │ │ ┌───── day of the month (1 - 31)
# │ │ │ ┌───── month (1 - 12)
# │ │ │ │ ┌───── day of the week (0 - 6) (Sunday to Saturday;7 is also Sunday on some systems)
# │ │ │ │ │        
# │ │ │ │ │
# * * * * * 
#
# Example: "45 23 * * 6", this will replicate data at 23:45 (11:45 PM) every Saturday.
# Default value is “00 08 * * *”, this will replicate data at  08:00AM daily.
**/
variable "replication_cron_spec" {
  description = "Enter the file share replication schedule in Linux crontab format."
  type        = string
  validation {
    condition     = can(regex("^([0-9]+|\\*|(\\*\\/[0-9]+))\\s([0-9]+|\\*|(\\*\\/[0-9]+))\\s([0-9]+|\\*|(\\*\\/[0-9]+))\\s([0-9]+|\\*|(\\*\\/[0-9]+))\\s([0-9]+|\\*|(\\*\\/[0-9]+))$", var.replication_cron_spec))
    error_message = "For the replication cron spec value only in cron spec format allowed."
  }
}

/**
#################################################################################################################
*                               End of the Variable Section 
#################################################################################################################
**/
