########################### File Share Creation
##################################################

resource "null_resource" "get_fs_ids" {
  depends_on = [ null_resource.delete_file_shares_mounts ]
  triggers = {
    vpc_api_endpoint = local.vpc_api_endpoint
    api_key = var.api_key
    share_name = lower ("${var.prefix}-${var.sap_sid}")
    region = var.region
    share_size = var.share_size
    share_profile = var.share_profile
    var_timeout = var.var_timeout
    zone = var.zone
    resource_group_id = var.resource_group_id
  }

  provisioner "local-exec" {
    when    = destroy

    command = "sleep ${self.triggers.var_timeout};export resource_group_id=${self.triggers.resource_group_id};export share_profile=${self.triggers.share_profile};export share_size=${self.triggers.share_size};export zone=${self.triggers.zone};export vpc_api_endpoint=${self.triggers.vpc_api_endpoint};export api_key=${self.triggers.api_key};export share_name=${self.triggers.share_name}; export region=${self.triggers.region}; chmod +x ${path.module}/get_fs_ids.sh;${path.module}/get_fs_ids.sh > ${path.module}/get_ids.log"
    interpreter = ["/bin/bash", "-c"]
    on_failure = continue
      }
    
}

resource "null_resource" "delete_file_shares_mounts" {
    depends_on = [ null_resource.delete_file_share ]
  #count = 1
  triggers = {
    vpc_api_endpoint = local.vpc_api_endpoint
    api_key = var.api_key
    share_name = lower ("${var.prefix}-${var.sap_sid}")
    region = var.region
    zone = var.zone
    share_size = var.share_size
    share_profile = var.share_profile
    resource_group_id = var.resource_group_id
  }

  provisioner "local-exec" {
    when    = destroy

    command = "export resource_group_id=${self.triggers.resource_group_id};export share_profile=${self.triggers.share_profile};export share_size=${self.triggers.share_size};export zone=${self.triggers.zone};export vpc_api_endpoint=${self.triggers.vpc_api_endpoint};export api_key=${self.triggers.api_key};export share_name=${self.triggers.share_name}; export region=${self.triggers.region};chmod +x ${path.module}/get_fs_ids.sh;${path.module}/get_fs_ids.sh ;chmod +x ${path.module}/delete_file_shares_mounts.sh; ${path.module}/delete_file_shares_mounts.sh > ${path.module}/dmfs.log"
    interpreter = ["/bin/bash", "-c"]
      }
}

resource "null_resource" "delete_file_share" {
    depends_on = [ null_resource.troubleshoot_fs_ids ]
  #count = 1
  triggers = {
    vpc_api_endpoint = local.vpc_api_endpoint
    api_key = var.api_key
    share_name = lower ("${var.prefix}-${var.sap_sid}")
    region = var.region
    resource_group_id = var.resource_group_id
  }

  provisioner "local-exec" {
    when    = destroy

    command = "export resource_group_id=${self.triggers.resource_group_id};export vpc_api_endpoint=${self.triggers.vpc_api_endpoint};export api_key=${self.triggers.api_key};export share_name=${self.triggers.share_name}; export region=${self.triggers.region};chmod +x ${path.module}/delete_file_share.sh; ${path.module}/delete_file_share.sh > ${path.module}/dfs.log"
    interpreter = ["/bin/bash", "-c"]
      }  
}

resource "null_resource" "troubleshoot_fs_ids" {
  triggers = {
    vpc_api_endpoint = local.vpc_api_endpoint
    api_key = var.api_key
    share_name = lower ("${var.prefix}-${var.sap_sid}")
    region = var.region
    share_size = var.share_size
    share_profile = var.share_profile
    var_timeout = var.var_timeout
    zone = var.zone
  }

  provisioner "local-exec" {
    when    = destroy

    command = "cat  ${path.module}/*.log"
    interpreter = ["/bin/bash", "-c"]
      }
    
}