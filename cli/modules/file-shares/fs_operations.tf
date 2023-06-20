########################### File Share Creation
##################################################

resource "time_sleep" "wait_for_FS_api" {
  create_duration = var.var_timeout
}

resource "null_resource" "create_file_share" {
  depends_on = [ time_sleep.wait_for_FS_api ]
    provisioner "local-exec" {
    command = "export resource_group_id=${var.resource_group_id };export vpc_api_endpoint=${local.vpc_api_endpoint}; export vpc_id=${var.vpc_id};export region=${var.region};export api_key=${var.api_key};export share_size=${var.share_size};export share_name=${local.share_name};export share_profile=${var.share_profile};export zone=${var.zone}; chmod +x ${path.module}/create_file_share.sh; ${path.module}/create_file_share.sh > ${path.module}/cfs.log"
    interpreter = ["/bin/bash", "-c"]
      }
}