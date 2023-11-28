resource "null_resource" "ansible-exec" {

  provisioner "local-exec" {
    command = "ansible-playbook --private-key ${var.ID_RSA_FILE_PATH} -i ansible/inventory.yml ansible/${var.PLAYBOOK}"
  }

  provisioner "local-exec" {
     command = "sed -i  's/${var.sap_main_password}/xxxxxxxx/' terraform.tfstate"
    }

  provisioner "local-exec" {
     command = "sed -i  's/${var.hana_main_password}/xxxxxxxx/' terraform.tfstate"
    }

  provisioner "local-exec" {
     command = "sed -i  's/${var.ha_password}/xxxxxxxx/' terraform.tfstate"
    }

# Could be disabled only for Dev purposes.
  provisioner "local-exec" {
       command = "sleep 20; rm -rf ansible/*-vars.yml; rm -f ansible/hana_volume_layout.json"
      }
}