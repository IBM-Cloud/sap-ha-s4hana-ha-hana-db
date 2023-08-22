module "pre-init" {
  source		= "./modules/pre-init"
}

module "precheck-ssh-exec" {
  source		= "./modules/precheck-ssh-exec"
  depends_on	= [ module.pre-init ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  HOSTNAME		= "${local.DB_HOSTNAME_1}"
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
  SAP_SID = var.SAP_SID
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
  PROFILE		= var.DB_PROFILE
  IMAGE			= var.DB_IMAGE
  SSH_KEYS		= var.SSH_KEYS
  SAP_SID = var.SAP_SID
  for_each ={
    "hanadb-1" = { DB-HOSTNAME = lower("${var.DB_HOSTNAME_1}") , DB-HOSTNAME-DEFAULT = lower("hanadb-${var.HANA_SID}-1"), DB_REAL_HOSTNAME = lower("${var.DB_HOSTNAME_1}") != "hanadb-1" ? lower("${var.DB_HOSTNAME_1}") : lower("hanadb-${var.HANA_SID}-1") }
    "hanadb-2" = { DB-HOSTNAME = lower("${var.DB_HOSTNAME_2}") , DB-HOSTNAME-DEFAULT = lower("hanadb-${var.HANA_SID}-2"), DB_REAL_HOSTNAME = lower("${var.DB_HOSTNAME_2}") != "hanadb-2" ? lower("${var.DB_HOSTNAME_2}") : lower("hanadb-${var.HANA_SID}-2") }
  }
  DB-HOSTNAME = "${each.value.DB-HOSTNAME}"
  INPUT-DEFAULT-HOSTNAME = "${each.key}"
  FINAL-DEFAULT-HOSTNAME = lower ("${each.value.DB-HOSTNAME-DEFAULT}")
  REAL_HOSTNAME = "${each.value.DB_REAL_HOSTNAME}"
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
  PROFILE		= var.APP_PROFILE
  IMAGE			= var.APP_IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "40" ]
  VOL_PROFILE		= "10iops-tier"
  SAP_SID = var.SAP_SID
  for_each ={
    "sapapp-1" = { APP-HOSTNAME = lower("${var.APP_HOSTNAME_1}") , APP-HOSTNAME-DEFAULT = lower("sapapp-${var.SAP_SID}-1"), APP_REAL_HOSTNAME = lower("${var.APP_HOSTNAME_1}") != "sapapp-1" ? lower("${var.APP_HOSTNAME_1}") : lower("sapapp-${var.SAP_SID}-1") }
    "sapapp-2" = { APP-HOSTNAME = lower("${var.APP_HOSTNAME_2}") , APP-HOSTNAME-DEFAULT = lower("sapapp-${var.SAP_SID}-2"), APP_REAL_HOSTNAME = lower("${var.APP_HOSTNAME_2}") != "sapapp-2" ? lower("${var.APP_HOSTNAME_2}") : lower("sapapp-${var.SAP_SID}-2") }
  }
  APP-HOSTNAME = "${each.value.APP-HOSTNAME}"
  INPUT-DEFAULT-HOSTNAME = "${each.key}"
  FINAL-DEFAULT-HOSTNAME = lower ("${each.value.APP-HOSTNAME-DEFAULT}")
  REAL_HOSTNAME = "${each.value.APP_REAL_HOSTNAME}"
}

module "file-shares" {
  depends_on	= [ module.vpc-subnet, module.pg ]
  source		= "./modules/file-shares"
  for_each = {
  "usrsap-as1" = {size = var.USRSAP_AS1 , var_name = "as1" }
  "usrsap-as2" = {size = var.USRSAP_AS2 , var_name = "as2" }
  "usrsap-sapascs" = {size = var.USRSAP_SAPASCS , var_name = "sapascs" }
  "usrsap-sapers" = {size = var.USRSAP_SAPERS , var_name = "sapers" }
  "usrsap-sapmnt" = {size = var.USRSAP_SAPMNT , var_name = "sapmnt" }
  "usrsap-sapsys" = {size = var.USRSAP_SAPSYS , var_name = "sapsys" }
  "usrsap-trans" = {size = var.USRSAP_TRANS , var_name = "trans" }
  }
  api_key   = var.IBMCLOUD_API_KEY
  resource_group_id     = data.ibm_resource_group.group.id
  zone                  = var.ZONE
  prefix                = each.key
  ansible_var_name      = each.value.var_name
  vpc_id                = data.ibm_is_vpc.vpc.id
  vpc			              = var.VPC
  region                = var.REGION
  share_size            = each.value.size
  share_profile         = var.SHARE_PROFILE
  sap_sid               = var.SAP_SID
}

module "alb-prereq" {
  depends_on	= [ module.file-shares ]
  source		= "./modules/alb/prereq"

  for_each ={
    "${local.SAP-ALB-ASCS}" = {syd = var.SAP_SID, delay ="1m"}
    "${local.SAP-ALB-ERS}"  = {syd = var.SAP_SID, delay ="3m"}
    "${local.DB-ALB-HANA}"  = {syd = var.HANA_SID, delay ="5m"}
  }

  SAP_ALB_NAME = "${each.key}"
  SAP_ALB_DELAY = "${each.value.delay}"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = "${each.value.syd}"
  HANA_SYSNO = var.HANA_SYSNO
  SAP_ASCS = var.SAP_ASCS_INSTANCE_NUMBER
  SAP_ERSNO = var.SAP_ERS_INSTANCE_NUMBER
}

module "alb-ascs" {
  depends_on	= [ module.alb-prereq, module.app-vsi, module.db-vsi ]
  source		= "./modules/alb"
  
  SAP_HEALTH_MONITOR_PORT_PREFIX = "36"
  SAP_HEALTH_MONITOR_PORT_POSTFIX = "${var.SAP_ASCS_INSTANCE_NUMBER}"
  
  for_each = {
  "backend-1" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "32" , port_postfix = "${var.SAP_ASCS_INSTANCE_NUMBER}", port_apostfix = ""}
  "backend-2" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "36" , port_postfix = "${var.SAP_ASCS_INSTANCE_NUMBER}", port_apostfix = ""}
  "backend-3" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "39" , port_postfix = "${var.SAP_ASCS_INSTANCE_NUMBER}", port_apostfix = ""}
  "backend-4" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "81" , port_postfix = "${var.SAP_ASCS_INSTANCE_NUMBER}", port_apostfix = ""}
  "backend-5" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "5" , port_postfix = "${var.SAP_ASCS_INSTANCE_NUMBER}", port_apostfix = "13"}
  "backend-6" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "5" , port_postfix = "${var.SAP_ASCS_INSTANCE_NUMBER}", port_apostfix = "14"}
  "backend-7" = { sap_alb_name ="${local.SAP-ALB-ASCS}", backend-name = "sap-ascs" , port_prefix = "5" , port_postfix = "${var.SAP_ASCS_INSTANCE_NUMBER}", port_apostfix = "16"}
  }
  SAP_ALB_NAME = "${each.value.sap_alb_name}"

  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.SAP_SID
  HANA_SYSNO = var.HANA_SYSNO
  SAP_ASCS = var.SAP_ASCS_INSTANCE_NUMBER
  SAP_ERSNO = var.SAP_ERS_INSTANCE_NUMBER
  SAP-PRIVATE-IP-VSI1 = "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
  SAP-PRIVATE-IP-VSI2 = "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
  SAP_BACKEND_POOL_NAME = lower ("${each.value.backend-name}-${var.SAP_SID}-${each.value.port_prefix}${var.SAP_ASCS_INSTANCE_NUMBER}${each.value.port_apostfix}")
  SAP_PORT_LB = "${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}"
}

module "alb-ers" {
  depends_on	= [ module.alb-prereq, module.app-vsi, module.db-vsi ]
  source		= "./modules/alb"
  
  SAP_HEALTH_MONITOR_PORT_PREFIX = "32"
  SAP_HEALTH_MONITOR_PORT_POSTFIX = "${var.SAP_ERS_INSTANCE_NUMBER}"
  
  for_each = {
  "backend-1" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "32" , port_postfix = "${var.SAP_ERS_INSTANCE_NUMBER}", port_apostfix = ""}
  "backend-2" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "33" , port_postfix = "${var.SAP_ERS_INSTANCE_NUMBER}", port_apostfix = ""}
  "backend-3" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "5" , port_postfix = "${var.SAP_ERS_INSTANCE_NUMBER}", port_apostfix = "13"}
  "backend-4" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "5" , port_postfix = "${var.SAP_ERS_INSTANCE_NUMBER}", port_apostfix = "14"}
  "backend-5" = { sap_alb_name ="${local.SAP-ALB-ERS}", backend-name = "sap-ers" , port_prefix = "5" , port_postfix = "${var.SAP_ERS_INSTANCE_NUMBER}", port_apostfix = "16"}
  }
  SAP_ALB_NAME = "${each.value.sap_alb_name}"

  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.SAP_SID
  HANA_SYSNO = var.HANA_SYSNO
  SAP_ASCS = var.SAP_ASCS_INSTANCE_NUMBER
  SAP_ERSNO = var.SAP_ERS_INSTANCE_NUMBER
  SAP-PRIVATE-IP-VSI1 = "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
  SAP-PRIVATE-IP-VSI2 = "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
  SAP_BACKEND_POOL_NAME = lower ("${each.value.backend-name}-${var.SAP_SID}-${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}")
  SAP_PORT_LB = "${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}"
}

module "alb-hana" {
  depends_on	= [ module.alb-prereq, module.app-vsi, module.db-vsi ]
  source		= "./modules/alb"
  
  SAP_HEALTH_MONITOR_PORT_PREFIX = "3"
  SAP_HEALTH_MONITOR_PORT_POSTFIX = "${var.HANA_SYSNO}13"
  
  for_each = {
  "backend-1" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "13"}
  "backend-2" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "14"}
  "backend-3" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "15"}
  "backend-4" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "40"}
  "backend-5" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "41"}
  "backend-6" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "3" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "42"}
  "backend-7" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "5" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "13"}
  "backend-8" = { sap_alb_name ="${local.DB-ALB-HANA}", backend-name = "db-hana" , port_prefix = "5" , port_postfix = "${var.HANA_SYSNO}", port_apostfix = "14"}
  }
  SAP_ALB_NAME = "${each.value.sap_alb_name}"

  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SAP_SID = var.HANA_SID
  HANA_SYSNO = var.HANA_SYSNO
  SAP_ASCS = var.SAP_ASCS_INSTANCE_NUMBER
  SAP_ERSNO = var.SAP_ERS_INSTANCE_NUMBER
  SAP-PRIVATE-IP-VSI1 = "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
  SAP-PRIVATE-IP-VSI2 = "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
  SAP_BACKEND_POOL_NAME = lower ("${each.value.backend-name}-${var.HANA_SID}-${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}")
  SAP_PORT_LB = "${each.value.port_prefix}${each.value.port_postfix}${each.value.port_apostfix}"
}

module "dns"  {
    depends_on	= [ module.alb-hana, module.alb-ers, module.alb-ascs ]
    source		= "./modules/dns"
    ZONE			= var.ZONE
    REGION  = var.REGION
    VPC			= var.VPC
    RESOURCE_GROUP = var.RESOURCE_GROUP
    SAP_SID = var.SAP_SID
    ALB_ASCS_HOSTNAME = "${data.ibm_is_lb.alb-ascs.hostname}"
    ALB_ERS_HOSTNAME = "${data.ibm_is_lb.alb-ers.hostname}"
    ALB_HANA_HOSTNAME =  "${data.ibm_is_lb.alb-hana.hostname}"
    DOMAIN_NAME = var.DOMAIN_NAME
    ASCS_VIRT_HOSTNAME = var.ASCS_VIRT_HOSTNAME != "sapascs" ? var.ASCS_VIRT_HOSTNAME : lower ("${local.ASCS_VIRT_HOSTNAME}")
    ERS_VIRT_HOSTNAME =  var.ERS_VIRT_HOSTNAME != "sapers" ? var.ERS_VIRT_HOSTNAME : lower ("${local.ERS_VIRT_HOSTNAME}") 
    HANA_VIRT_HOSTNAME = var.HANA_VIRT_HOSTNAME != "dbhana" ? var.HANA_VIRT_HOSTNAME : lower ("${local.HANA_VIRT_HOSTNAME}")
}

module "ansible-deployment" {
  source		= "./modules/ansible-exec"
  depends_on	= [ local_file.ansible_inventory, local_file.ha_ansible_infra-vars, local_file.app_ansible_saps4app-vars, local_file.db_ansible_saphana-vars, local_file.tf_ansible_hana_storage_generated_file, module.alb-hana, module.app-vsi, module.db-vsi, module.file-shares, module.dns ]
  IP			= data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address
  PLAYBOOK = "playbook.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}
