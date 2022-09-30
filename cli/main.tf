module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "pg" {
  source		= "./modules/pg"
  ZONE			= var.ZONE
  VPC			= var.VPC
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.sap_sid
}

module "db-vsi" {
  depends_on	= [ module.pg ]
  source		= "./modules/db-vsi"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  PLACEMENT_GROUP	= module.pg.PLACEMENT_GROUP
  PROFILE		= var.DB-PROFILE
  IMAGE			= var.DB-IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "500" , "500" , "500" , "500" , "500" , "500" ]
  VOL_PROFILE	= "custom"
  VOL_IOPS		= "10000"
  SAP_SID = var.sap_sid
}

module "app-vsi" {
  depends_on	= [ module.pg ]
  source		= "./modules/app-vsi"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  PLACEMENT_GROUP	= module.pg.PLACEMENT_GROUP
  PROFILE		= var.APP-PROFILE
  IMAGE			= var.APP-IMAGE
  SSH_KEYS		= var.SSH_KEYS
  SAP_SID = var.sap_sid
}

module "file-shares" {
  depends_on	= [ module.vpc-subnet , module.app-vsi]
  source		= "./modules/file-shares"
  for_each = {
  "usrsap-as1" = var.usrsap-as1
  "usrsap-as2" = var.usrsap-as2
  "usrsap-sapascs" = var.usrsap-sapascs
  "usrsap-sapers" = var.usrsap-sapers
  "usrsap-sapmnt" = var.usrsap-sapmnt
  "usrsap-sapsys" = var.usrsap-sapsys
  "usrsap-trans" = var.usrsap-trans
  }
  api_key   = var.ibmcloud_api_key
  resource_group_name   = data.ibm_resource_group.group.id
  zone                  = var.ZONE
  prefix                = each.key
  vpc_id                = data.ibm_is_vpc.vpc.id
  region                = var.REGION
  enable_file_share     = true
  share_size            = each.value
  share_profile         = var.share_profile
  replica_zone          = var.replica_zone
  replication_cron_spec = var.replication_cron_spec
  SAP_SID = var.sap_sid
}

/*
module "db-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-vsi , local_file.db_ansible_saphana-vars ]
  IP1			= module.db-vsi.HANA-DB-PRIVATE-IP-VSI1
  IP2			= module.db-vsi.HANA-DB-PRIVATE-IP-VSI2
  PLAYBOOK_PATH = "ansible/saphana.yml"
}

module "app-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-ansible-exec , module.app-vsi , local_file.app_ansible_saps4app-vars ]
  IP1			= module.app-vsi.SAP-APP-PRIVATE-IP-VSI1
  IP2			= module.app-vsi.SAP-APP-PRIVATE-IP-VSI2
  PLAYBOOK_PATH = "ansible/saps4app.yml"
}


module "sec-exec" {
  source		= "./modules/sec-exec"
  depends_on	= [ module.app-ansible-exec ]
  sap_main_password = var.sap_main_password
  hana_main_password = var.hana_main_password
}

*/
