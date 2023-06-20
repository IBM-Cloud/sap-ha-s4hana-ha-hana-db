/**
#################################################################################################################
*                                 File Share Module Output Variable Section
#################################################################################################################
**/

## Creating ansible file share vars.
resource "local_file" "file_share-vars" {
  depends_on = [ null_resource.create_file_share ]
  content = <<-DOC
 ${var.ansible_var_name}_share_name: "${local.share_name}"
 ${var.ansible_var_name}_mount_path: "${local.mount_path}"
    DOC
  filename = "ansible/fileshare_${local.share_name}.yml"
}