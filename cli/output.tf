
output "HANA-DB-HOSTNAMES" {
  value		= module.db-vsi.HOSTNAME
}

output "HANA-DB-PRIVATE-IPs" {
  value		= module.db-vsi.PRIVATE-IP
}

output "SAP-APP-HOSTNAMES" {
  value		= module.app-vsi.HOSTNAME
}

output "SAP-APP-PRIVATE-IPs" {
  value		= module.app-vsi.PRIVATE-IP
}