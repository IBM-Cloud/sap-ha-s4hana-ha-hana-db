resource "time_sleep" "wait_for_updates" {
  create_duration = "${var.SAP_ALB_DELAY}"
}

resource "ibm_is_lb" "sap-alb" {
  depends_on      = [time_sleep.wait_for_updates]
  name    = lower ("${var.SAP_ALB_NAME}-${var.SAP_SID}")
  subnets = [data.ibm_is_subnet.subnet.id]
  resource_group = data.ibm_resource_group.group.id
  security_groups = [data.ibm_is_security_group.securitygroup.id]
  type    = "private"
  timeouts {
    create = "2h"
    delete = "2h"
  }
}
