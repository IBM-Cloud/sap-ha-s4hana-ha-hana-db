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

  ### Replica File Share related Variables
  replica_name        = "${local.share_name}-replica"
  replica_zone        = var.replica_zone
  replica_target_name = "${local.replica_name}"

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

  ## Replica File Share
  replicaShareData = jsonencode(
    {
      "source_share" : { "id" : "${local.fsID}" },
      "name" : "${local.replica_name}",
      "profile" : { "name" : "${local.share_profile}" },
      "replication_cron_spec" : "${var.replication_cron_spec}",
      "targets" : [{ "name" : "${local.replica_target_name}", "vpc" : { "id" : "${var.vpc_id}" } }],
      "zone" : { "name" : "${local.replica_zone}" },
  })
}

data "http" "create_replica_file_share" {
  count    = var.enable_file_share == true ? 1 : 0
  provider = http-full
  url      = local.shareUrl
  method   = "POST"
  request_headers = {
    Accept        = "application/json"
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  request_body = local.replicaShareData
  depends_on   = [time_sleep.wait_90_seconds, data.http.create_file_share]
}

locals {
  share_id            = local.fsID
  share_target_id     = local.fsTargetID
  share_target_url    = var.enable_file_share == true ? "${local.host}/${local.fsID}/targets/${local.fsTargetID}${local.query_string}" : ""
  response_replica_fs = var.enable_file_share == true ? jsondecode(data.http.create_replica_file_share[0].response_body) : null
  rs_id               = local.response_replica_fs != null ? local.response_replica_fs.id : 0
  rs_target_id        = local.response_replica_fs != null ? local.response_replica_fs.targets[0].id : 0
}

data "http" "mount_target" {
  count = var.enable_file_share == true ? 1 : 0
  url   = local.share_target_url
  request_headers = {
    Accept        = "application/json"
    Authorization = "${data.ibm_iam_auth_token.auth_token.iam_access_token}"
  }
  depends_on = [data.http.create_replica_file_share, ]
}


########################### File Share Deletion
##################################################

locals {
  replica_share_id         = local.rs_id
  replica_share_target_id  = local.rs_target_id
  replica_share_target_url = var.enable_file_share == true ? "${local.host}/${local.replica_share_id}/targets/${local.replica_share_target_id}?generation=2&version=${local.date}" : ""
  getFileShareUrl          = "${local.host}${local.query_string}&replication_role=source&name=${local.share_name}"
}

locals {
  targetData = var.enable_file_share == true ? jsondecode(data.http.mount_target[0].response_body) : null
}

resource "time_sleep" "timeout_1_minute" {
  create_duration = "1m"
}

resource "null_resource" "delete_file_share" {
  triggers = {
    host                    = local.host
    replica_share_target_id = local.replica_share_target_id
    replica_share_id        = local.replica_share_id
    share_target_id         = local.share_target_id
    share_id                = local.share_id
    api_key                 = var.api_key
    region                  = var.region
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
     echo 'Login to ibmcloud'
     ibmcloud config --check-version=false
     ibmcloud login -r ${self.triggers.region} --apikey ${self.triggers.api_key}  
     export oauth_token=` ibmcloud iam oauth-tokens |awk '{print $4}'`
     sleep 3
     curl -X DELETE "${self.triggers.host}/${self.triggers.share_id}?version=2022-05-03&generation=2" -H "Authorization: $oauth_token"
     sleep 3
     export oauth_token=` ibmcloud iam oauth-tokens |awk '{print $4}'` 
     curl -X DELETE "${self.triggers.host}/${self.triggers.replica_share_id}?version=2022-05-03&generation=2" -H "Authorization: $oauth_token" 
    EOT
  }
  depends_on = [time_sleep.wait_90_seconds, data.http.create_file_share , time_sleep.timeout_1_minute, ]
}

resource "null_resource" "delete_file_share_replica_relation" {
  triggers = {
    host                    = local.host
    replica_share_target_id = local.replica_share_target_id
    replica_share_id        = local.replica_share_id
    share_target_id         = local.share_target_id
    share_id                = local.share_id
    api_key                 = var.api_key
    region                  = var.region
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
     echo 'Login to ibmcloud'
     ibmcloud config --check-version=false
     ibmcloud login -r ${self.triggers.region} --apikey ${self.triggers.api_key}  
     export oauth_token=` ibmcloud iam oauth-tokens |awk '{print $4}'`     
     curl -X DELETE "${self.triggers.host}/${self.triggers.replica_share_id}/source?version=2022-05-03&generation=2" -H "Authorization: $oauth_token"
     sleep 10
    EOT
  }
  depends_on = [
    null_resource.delete_file_share,
  ]
}

resource "null_resource" "delete_file_shares_mounts" {
  triggers = {
    host                    = local.host
    replica_share_target_id = local.replica_share_target_id
    replica_share_id        = local.replica_share_id
    share_target_id         = local.share_target_id
    share_id                = local.share_id
    api_key                 = var.api_key
    region                  = var.region
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
     echo 'Login to ibmcloud'
     ibmcloud config --check-version=false
     ibmcloud login -r ${self.triggers.region} --apikey ${self.triggers.api_key}  
     export oauth_token=` ibmcloud iam oauth-tokens |awk '{print $4}'`     
     curl -X DELETE "${self.triggers.host}/${self.triggers.replica_share_id}/targets/${self.triggers.replica_share_target_id}?version=2022-05-03&generation=2" -H "Authorization: $oauth_token"
     curl -X DELETE "${self.triggers.host}/${self.triggers.share_id}/targets/${self.triggers.share_target_id}?version=2022-05-03&generation=2" -H "Authorization: $oauth_token"
     sleep 10
    EOT
  }
  depends_on = [
    null_resource.delete_file_share, null_resource.delete_file_share_replica_relation,
  ]
}