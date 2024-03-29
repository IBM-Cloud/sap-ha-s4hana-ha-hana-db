
#############################################################
# Export Terraform variable values to an Ansible var_file.
#############################################################

#### HA Infra variables.

resource "local_file" "ha_ansible_infra-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.

# INFRA variables
api_key: "${var.IBMCLOUD_API_KEY}"
region: "${var.REGION}"
ha_password: "${var.HA_PASSWORD}"

hdb_iphost1: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
hdb_iphost2: "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
hdb_hostname1: "${data.ibm_is_instance.db-vsi-1.name}"
hdb_hostname2: "${data.ibm_is_instance.db-vsi-2.name}"

app_iphost1: "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
app_iphost2: "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
app_hostname1: "${data.ibm_is_instance.app-vsi-1.name}"
app_hostname2: "${data.ibm_is_instance.app-vsi-2.name}"

app_instanceid1: "${data.ibm_is_instance.app-vsi-1.id}"
app_instanceid2: "${data.ibm_is_instance.app-vsi-2.id}"
hdb_instanceid1: "${data.ibm_is_instance.db-vsi-1.id}"
hdb_instanceid2: "${data.ibm_is_instance.db-vsi-2.id}"

alb_ascs_hostname: "${data.ibm_is_lb.alb-ascs.hostname}"
alb_ers_hostname: "${data.ibm_is_lb.alb-ers.hostname}"
alb_hana_hostname: "${data.ibm_is_lb.alb-hana.hostname}"
...
    DOC
  filename = "ansible/hainfra-vars.yml"
}


#### Ansible inventory.

resource "local_file" "ansible_inventory" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
all:
  hosts:
    hdb_iphost1:
      ansible_host: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    hdb_iphost2:
      ansible_host: "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
    app_iphost1:
      ansible_host: "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    app_iphost2:
      ansible_host: "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
    DOC
  filename = "ansible/inventory.yml"
}

#### SAP-APP variables.

resource "local_file" "app_ansible_saps4app-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.

# SAP system configuration
s4hana_version: "${var.S4HANA_VERSION}"
sap_sid: "${var.SAP_SID}"
sap_ascs_instance_number: "${var.SAP_ASCS_INSTANCE_NUMBER}"
sap_ers_instance_number: "${var.SAP_ERS_INSTANCE_NUMBER}"
sap_ci_instance_number: "${var.SAP_CI_INSTANCE_NUMBER}"
sap_aas_instance_number: "${var.SAP_AAS_INSTANCE_NUMBER}"
sap_main_password: "${var.SAP_MAIN_PASSWORD}"

hdb_concurrent_jobs: "${var.HDB_CONCURRENT_JOBS}"

# SAP S/4HANA APP Installation kit path
kit_sapcar_file: "${var.KIT_SAPCAR_FILE}"
kit_swpm_file: "${var.KIT_SWPM_FILE}"
kit_sapexe_file: "${var.KIT_SAPEXE_FILE}"
kit_sapexedb_file: "${var.KIT_SAPEXEDB_FILE}"
kit_igsexe_file: "${var.KIT_IGSEXE_FILE}"
kit_igshelper_file: "${var.KIT_IGSHELPER_FILE}"
kit_saphotagent_file: "${var.KIT_SAPHOSTAGENT_FILE}"
kit_hdbclient_file: "${var.KIT_HDBCLIENT_FILE}"
kit_s4hana_export: "${var.KIT_S4HANA_EXPORT}"
...
    DOC
  filename = "ansible/saps4app-vars.yml"
}

#### HANADB variables.

resource "local_file" "db_ansible_saphana-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.
hana_profile: "${var.DB_PROFILE}"

# HANA DB configuration
hana_sid: "${var.HANA_SID}"
hana_sysno: "${var.HANA_SYSNO}"
hana_main_password: "${var.HANA_MAIN_PASSWORD}"
hana_system_usage: "${var.HANA_SYSTEM_USAGE}"
hana_components: "${var.HANA_COMPONENTS}"

# SAP HANA Installation kit path
kit_saphana_file: "${var.KIT_SAPHANA_FILE}"
...
    DOC
  filename = "ansible/saphana-vars.yml"
}

#### Integrate all variables for sap file shares in one.

resource "null_resource" "file_shares_ansible_vars" {
  depends_on = [module.file-shares]

  provisioner "local-exec" {
    working_dir = "ansible"
    command = <<EOF
    echo -e "---\n`cat fileshare_*`\n...\n" > fileshares-vars.yml; rm -rf fileshare_*; echo done
      EOF
      }
}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_hana_storage_generated_file" {
  depends_on = [ module.db-vsi ]
  source = "files/hana_volume_layout.json"
  filename = "ansible/hana_volume_layout.json"
}
