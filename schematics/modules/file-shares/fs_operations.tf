########################### File Share Creation
##################################################

locals {
  date         = formatdate("YYYY-MM-DD", timestamp())
  host         = "https://${var.region}.iaas.cloud.ibm.com/v1/shares"
  query_string = "?generation=2&version=${local.date}"
  shareUrl     = "${local.host}${local.query_string}"

  ### File Share related Variables
  share_size    = var.share_size
  share_name    = lower ("${var.prefix}-${var.SAP_SID}")
  share_profile = var.share_profile
  target_name   = "${local.share_name}"

  ### FileShare Data
  fileShareData = jsonencode(
    {
      "size" : "${local.share_size}",
      "targets" : [{ "name" : "${local.target_name}", "vpc" : { "id" : "${var.vpc_id}" } }],
      "name" : "${local.share_name}",
      "profile" : { "name" : "${local.share_profile}" },
      "zone" : { "name" : "${var.zone}" },
      "resource_group" : { "id" : "${var.resource_group_name}" },
  })
}

data "ibm_iam_auth_token" "auth_token" {}

data "http" "create_file_share" {
  count    = var.enable_file_share == true ? 1 : 0
  provider = http-full
  url      = local.shareUrl
  method   = "POST"
  request_headers = {
    Accept        = "application/json"
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  request_body = local.fileShareData
}

resource "time_sleep" "wait_90_seconds" {
  count           = var.enable_file_share == true ? 1 : 0
  depends_on      = [data.http.create_file_share]
  create_duration = "90s"
}

locals {
  response_fs = var.enable_file_share == true ? jsondecode(data.http.create_file_share[0].response_body) : null
  fsID        = local.response_fs != null ? local.response_fs.id : 0
  fsTargetID  = local.response_fs != null ? local.response_fs.targets[0].id : 0
}

locals {
  share_id            = local.fsID
  share_target_id     = local.fsTargetID
  share_target_url    = var.enable_file_share == true ? "${local.host}/${local.fsID}/targets/${local.fsTargetID}${local.query_string}" : ""
}

data "http" "mount_target" {
  count = var.enable_file_share == true ? 1 : 0
  url   = local.share_target_url
  request_headers = {
    Accept        = "application/json"
    Authorization = "${data.ibm_iam_auth_token.auth_token.iam_access_token}"
  }
  depends_on   = [time_sleep.wait_90_seconds, data.http.create_file_share]
}


########################### File Share Deletion
##################################################

locals {
  getFileShareUrl          = "${local.host}${local.query_string}&replication_role=source&name=${local.share_name}"
}

locals {
  targetData = var.enable_file_share == true ? jsondecode(data.http.mount_target[0].response_body) : null
}

resource "time_sleep" "timeout_2_minutes" {
  create_duration = "2m"
}

resource "null_resource" "delete_file_share" {
  count = 5
  triggers = {
    host                    = local.host
    share_target_id         = local.share_target_id
    share_id                = local.share_id
    api_key                 = var.api_key
    region                  = var.region
  }

    provisioner "local-exec" {
    when    = destroy
    command = "export self_triggers_region=${self.triggers.region};export self_triggers_api_key=${self.triggers.api_key};export self_triggers_host=${self.triggers.host};export self_triggers_share_id=${self.triggers.share_id};export self_triggers_share_target_id=${self.triggers.share_target_id};chmod +x ${path.module}/delete_file_share.sh;/bin/bash ${path.module}/delete_file_share.sh"
    interpreter = ["/bin/bash", "-c"]
      }
  depends_on = [time_sleep.wait_90_seconds, data.http.create_file_share , time_sleep.timeout_2_minutes, ]

}
  
resource "null_resource" "delete_file_shares_mounts" {
  count = 5
  triggers = {
    host                    = local.host
    share_target_id         = local.share_target_id
    share_id                = local.share_id
    api_key                 = var.api_key
    region                  = var.region
  }

  provisioner "local-exec" {
    when    = destroy
    command = "export self_triggers_region=${self.triggers.region};export self_triggers_api_key=${self.triggers.api_key};export self_triggers_host=${self.triggers.host};export self_triggers_share_id=${self.triggers.share_id};export self_triggers_share_target_id=${self.triggers.share_target_id};chmod +x ${path.module}/delete_file_shares_mounts.sh;/bin/bash ${path.module}/delete_file_shares_mounts.sh"
  interpreter = ["/bin/bash", "-c"]
      }
    
  depends_on = [
    null_resource.delete_file_share,
  ]
}
