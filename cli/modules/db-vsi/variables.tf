variable "ZONE" {
    type = string
    description = "Cloud Zone"
}

variable "VPC" {
    type = string
    description = "VPC name"
}

variable "PLACEMENT_GROUP" {
    type = string
    description = "Placement Group"
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

variable "PROFILE" {
    type = string
    description = "VSI Profile"
}

variable "IMAGE" {
    type = string
    description = "VSI OS Image"
}

variable "SSH_KEYS" {
    type = list(string)
    description = "List of SSH Keys to access the VSI"
}

variable "VOLUME_SIZES" {
    type = list(string)
    description = "List of volume sizes in GB to be created"
}

variable "VOL_PROFILE" {
    type = string
    description = "Volume profile"
}

variable "VOL_IOPS" {
    type = string
    description = "Volume IOPS"
}

locals {
  HOSTNAME = "hanadb-${var.SAP_SID}"

  vol0 = toset([
    "0",
    "1",
    "2",
    ])

  vol1 = toset([
    "3",
    "4",
    "5",
    ])  
}

variable "SAP_SID" {
    type = string
    description = "SAP SID"
}