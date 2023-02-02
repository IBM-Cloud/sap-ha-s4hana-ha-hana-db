output "HANA-DB-PRIVATE-IP-VSI1" {
  value		= "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "HANA-DB-PRIVATE-IP-VSI2" {
  value		= "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "SAP-APP-PRIVATE-IP-VSI1" {
  value		= "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "SAP-APP-PRIVATE-IP-VSI2" {
  value		= "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "DOMAIN-NAME" {
  value = var.DOMAIN_NAME
}

output FQDN-ALB-ASCS {
 value		= "${data.ibm_is_lb.alb-ascs.hostname}" 
}

output FQDN-ALB-ERS {
 value		= "${data.ibm_is_lb.alb-ers.hostname}"
}

output FQDN-ALB-HANA {
 value		= "${data.ibm_is_lb.alb-hana.hostname}"
}