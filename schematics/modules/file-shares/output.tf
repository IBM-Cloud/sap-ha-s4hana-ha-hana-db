/**
#################################################################################################################
*                                 File Share Module Output Variable Section
#################################################################################################################
**/

/* Output Variable for File Share
* This variable will return File share name.
**/
output "share_name" {
  value = local.share_name
}

/* Output Variable for File Share.
* This variable will return File share ID
**/

output "FILE_SHARE" {
  value =  merge(
      { "ID" = local.fsID },
      { "TARGET_ID" = local.fsTargetID }
    ) 
}

/** Output variable For Mount Path.
* This variable will return the File share target mount path used for mounting nfs in app servers.
**/

output "mountPath" {
  value = local.targetData != null ? local.targetData.mount_path : ""
}

## Creating ansible file share vars.
resource "local_file" "file_share-vars" {
  depends_on = [ data.http.create_file_share ]
  content = <<-DOC
 ${var.ansible_var_name}_share_name: "${local.share_name}"
 ${var.ansible_var_name}_mount_path: "${local.targetData != null ? local.targetData.mount_path : ""}"
    DOC
  filename = "ansible/fileshare_${local.share_name}.yml"
}