module "pre-init" {
  source		= "./modules/pre-init"
}

module "precheck-ssh-exec" {
  source		= "./modules/precheck-ssh-exec"
  depends_on	= [ module.pre-init ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  private_ssh_key = var.private_ssh_key
  HOSTNAME		= "${local.DB-HOSTNAME-1}"
  SECURITY_GROUP = var.SECURITY_GROUP
}

module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "pg" {
  source		= "./modules/pg"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.sap_sid
}

module "db-vsi" {
  depends_on	= [ module.file-shares ]
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
  VOLUME_SIZES	= [ "500" , "500" , "500" , "10" ]
  VOL_PROFILE		= "10iops-tier"
  SAP_SID = var.sap_sid
  for_each ={
    "hanadb-1" = {DB-HOSTNAME = "${var.DB-HOSTNAME-1}" , DB-HOSTNAME-DEFAULT = "hanadb-${var.hana_sid}-1"}
    "hanadb-2" = {DB-HOSTNAME = "${var.DB-HOSTNAME-2}" , DB-HOSTNAME-DEFAULT = "hanadb-${var.hana_sid}-2"}
  }
  DB-HOSTNAME = "${each.value.DB-HOSTNAME}"
  INPUT-DEFAULT-HOSTNAME = "${each.key}"
  FINAL-DEFAULT-HOSTNAME = lower ("${each.value.DB-HOSTNAME-DEFAULT}")

}

module "app-vsi" {
  depends_on	= [ module.file-shares ]
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
  VOLUME_SIZES	= [ "40" ]
  VOL_PROFILE		= "10iops-tier"
  SAP_SID = var.sap_sid
  for_each ={
    "sapapp-1" = {APP-HOSTNAME = "${var.APP-HOSTNAME-1}" , APP-HOSTNAME-DEFAULT = "sapapp-${var.sap_sid}-1"}
    "sapapp-2" = {APP-HOSTNAME = "${var.APP-HOSTNAME-2}" , APP-HOSTNAME-DEFAULT = "sapapp-${var.sap_sid}-2"}
  }
  APP-HOSTNAME = "${each.value.APP-HOSTNAME}"
  INPUT-DEFAULT-HOSTNAME = "${each.key}"
  FINAL-DEFAULT-HOSTNAME = lower ("${each.value.APP-HOSTNAME-DEFAULT}")
}


module "file-shares" {
  depends_on	= [ module.vpc-subnet , module.pg ]
  source		= "./modules/file-shares"
  for_each = {
  "usrsap-as1" = {size = var.usrsap-as1 , var_name = "as1" }
  "usrsap-as2" = {size = var.usrsap-as2 , var_name = "as2" }
  "usrsap-sapascs" = {size = var.usrsap-sapascs , var_name = "sapascs" }
  "usrsap-sapers" = {size = var.usrsap-sapers , var_name = "sapers" }
  "usrsap-sapmnt" = {size = var.usrsap-sapmnt , var_name = "sapmnt" }
  "usrsap-sapsys" = {size = var.usrsap-sapsys , var_name = "sapsys" }
  "usrsap-trans" = {size = var.usrsap-trans , var_name = "trans" }
  }
  api_key   = var.ibmcloud_api_key
  resource_group_name   = data.ibm_resource_group.group.id
  zone                  = var.ZONE
  prefix                = each.key
  ansible_var_name      = each.value.var_name
  vpc_id                = data.ibm_is_vpc.vpc.id
  region                = var.REGION
  enable_file_share     = true
  share_size            = each.value.size
  share_profile         = var.share_profile
  SAP_SID = var.sap_sid
}

module "alb-prereq" {
  depends_on	= [ module.file-shares ]
  source		= "./modules/alb/prereq"

  for_each ={
    "${local.SAP-ALB-ASCS}" = {syd = var.sap_sid, delay ="1m"}
    "${local.SAP-ALB-ERS}"  = {syd = var.sap_sid, delay ="3m"}
    "${local.DB-ALB-HANA}"  = {syd = var.hana_sid, delay ="5m"}
  }

  SAP_ALB_NAME = "${each.key}"
  SAP_ALB_DELAY = "${each.value.delay}"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = "${each.value.syd}"
  HANA_SYSNO = var.hana_sysno
  SAP_ASCS = var.sap_ascs_instance_number
  SAP_ERSNO = var.sap_ers_instance_number
}

module "alb-ascs" {
  depends_on	= [ module.alb-prereq , module.app-vsi ]
  source		= "./modules/alb"
  
  SAP_HEALTH_MONITOR_PORT_PREFIX = "36"
  SAP_HEALTH_MONITOR_PORT_POSTFIX = "${var.sap_ascs_instance_number}"
  
  for_each = {
  "backend-1" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "32" , port_postfix = "${var.sap_ascs_instance_number}", port_apostfix = ""}
  "backend-2" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "36" , port_postfix = "${var.sap_ascs_instance_number}", port_apostfix = ""}
  "backend-3" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "39" , port_postfix = "${var.sap_ascs_instance_number}", port_apostfix = ""}
  "backend-4" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "81" , port_postfix = "${var.sap_ascs_instance_number}", port_apostfix = ""}
  "backend-5" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "5" , port_postfix = "${var.sap_ascs_instance_number}", port_apostfix = "13"}
  "backend-6" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "5" , port_postfix = "${var.sap_ascs_instance_number}", port_apostfix = "14"}
  "backend-7" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "5" , port_postfix = "${var.sap_ascs_instance_number}", port_apostfix = "16"}
  }
  SAP_ALB_NAME = "${each.value.sap_alb_name}"

  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.sap_sid
  HANA_SYSNO = var.hana_sysno
  SAP_ASCS = var.sap_ascs_instance_number
  SAP_ERSNO = var.sap_ers_instance_number
  SAP-PRIVATE-IP-VSI1 = "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
  SAP-PRIVATE-IP-VSI2 = "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
  SAP_BACKEND_POOL_NAME = lower ("${each.value.backend-name}-${var.sap_sid}-${each.value.port_prefix}${var.sap_ascs_instance_number}${each.value.port_apostfix}")
  SAP_PORT_LB = "${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}"
}

module "alb-ers" {
  depends_on	= [ module.alb-prereq ,module.app-vsi ]
  source		= "./modules/alb"
  
  SAP_HEALTH_MONITOR_PORT_PREFIX = "32"
  SAP_HEALTH_MONITOR_PORT_POSTFIX = "${var.sap_ers_instance_number}"
  
  for_each = {
  "backend-1" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "32" , port_postfix = "${var.sap_ers_instance_number}", port_apostfix = ""}
  "backend-2" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "33" , port_postfix = "${var.sap_ers_instance_number}", port_apostfix = ""}
  "backend-3" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "5" , port_postfix = "${var.sap_ers_instance_number}", port_apostfix = "13"}
  "backend-4" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "5" , port_postfix = "${var.sap_ers_instance_number}", port_apostfix = "14"}
  "backend-5" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "5" , port_postfix = "${var.sap_ers_instance_number}", port_apostfix = "16"}
  }
  SAP_ALB_NAME = "${each.value.sap_alb_name}"

  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.sap_sid
  HANA_SYSNO = var.hana_sysno
  SAP_ASCS = var.sap_ascs_instance_number
  SAP_ERSNO = var.sap_ers_instance_number
  SAP-PRIVATE-IP-VSI1 = "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
  SAP-PRIVATE-IP-VSI2 = "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
  SAP_BACKEND_POOL_NAME = lower ("${each.value.backend-name}-${var.sap_sid}-${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}")
  SAP_PORT_LB = "${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}"
}

module "alb-hana" {
  depends_on	= [ module.alb-prereq , module.db-vsi ]
  source		= "./modules/alb"
  
  SAP_HEALTH_MONITOR_PORT_PREFIX = "3"
  SAP_HEALTH_MONITOR_PORT_POSTFIX = "${var.hana_sysno}13"
  
  for_each = {
  "backend-1" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.hana_sysno}", port_apostfix = "13"}
  "backend-2" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.hana_sysno}", port_apostfix = "14"}
  "backend-3" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.hana_sysno}", port_apostfix = "15"}
  "backend-4" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.hana_sysno}", port_apostfix = "40"}
  "backend-5" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.hana_sysno}", port_apostfix = "41"}
  "backend-6" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.hana_sysno}", port_apostfix = "42"}
  "backend-7" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "5" , port_postfix = "${var.hana_sysno}", port_apostfix = "13"}
  "backend-8" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "5" , port_postfix = "${var.hana_sysno}", port_apostfix = "14"}
  }
  SAP_ALB_NAME = "${each.value.sap_alb_name}"

  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.hana_sid
  HANA_SYSNO = var.hana_sysno
  SAP_ASCS = var.sap_ascs_instance_number
  SAP_ERSNO = var.sap_ers_instance_number
  SAP-PRIVATE-IP-VSI1 = "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
  SAP-PRIVATE-IP-VSI2 = "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
  SAP_BACKEND_POOL_NAME = lower ("${each.value.backend-name}-${var.hana_sid}-${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}")
  SAP_PORT_LB = "${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}"
}

module "dns"  {
    depends_on	= [ module.alb-hana ]
    source		= "./modules/dns"
    ZONE			= var.ZONE
    REGION  = var.REGION
    VPC			= var.VPC
    RESOURCE_GROUP = var.RESOURCE_GROUP
    SAP_SID = var.sap_sid
    ALB_ASCS_HOSTNAME = "${data.ibm_is_lb.alb-ascs.hostname}"
    ALB_ERS_HOSTNAME = "${data.ibm_is_lb.alb-ers.hostname}"
    ALB_HANA_HOSTNAME =  "${data.ibm_is_lb.alb-hana.hostname}"
    DOMAIN_NAME = var.DOMAIN_NAME
    ASCS-VIRT-HOSTNAME = var.ASCS-VIRT-HOSTNAME != "sapascs" ? var.ASCS-VIRT-HOSTNAME : lower ("${local.ASCS-VIRT-HOSTNAME}")
    ERS-VIRT-HOSTNAME =  var.ERS-VIRT-HOSTNAME != "sapers" ? var.ERS-VIRT-HOSTNAME : lower ("${local.ERS-VIRT-HOSTNAME}") 
    HANA-VIRT-HOSTNAME = var.HANA-VIRT-HOSTNAME != "dbhana" ? var.HANA-VIRT-HOSTNAME : lower ("${local.HANA-VIRT-HOSTNAME}")
}


module "ansible-deployment" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.app-vsi, local_file.ansible_inventory, local_file.ha_ansible_infra-vars, local_file.app_ansible_saps4app-vars, local_file.db_ansible_saphana-vars, module.file-shares, module.dns ]
  IP			= data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address
  PLAYBOOK = "playbook.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  private_ssh_key = var.private_ssh_key
}
