# Lists
output "HOSTNAME" {
  value		= tolist(ibm_is_instance.vsi[*].name)
}


output "PRIVATE-IP" {
  value		= toset(ibm_is_instance.vsi[*].primary_network_interface[0].primary_ipv4_address)
}


# ONE
output "HANA-DB-PRIVATE-IP-VSI1" {
  value		= ibm_is_instance.vsi[0].primary_network_interface[0].primary_ipv4_address
}

output "HANA-DB-PRIVATE-IP-VSI2" {
  value		= ibm_is_instance.vsi[1].primary_network_interface[0].primary_ipv4_address
}