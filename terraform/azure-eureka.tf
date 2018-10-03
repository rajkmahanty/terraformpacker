# Define resource group
data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group}"
}

data "azurerm_image" "image" {
  name_regex = "eureka-ubuntu-16.04-*"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}


# Define Manage Disk
resource "azurerm_managed_disk" "manage_disk" {
  name                 = "datadisk_existing"
  location             = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name  = "${data.azurerm_resource_group.resource_group.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

# Launch Virtual Machine
resource "azurerm_virtual_machine" "eureka_server" {
  name                  = "eureka-server"
  location              = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name   = "${data.azurerm_resource_group.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.network_interface.id}"]
  vm_size               = "${var.vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    id="${data.azurerm_image.image.id}"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "datadisk_new"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.manage_disk.name}"
    managed_disk_id = "${azurerm_managed_disk.manage_disk.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.manage_disk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${var.computer_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys = [{
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }]
  }

  tags {
    environment = "staging"
  }
 
provisioner "file" {
   source = "/var/lib/jenkins/workspace/Eureka_Execution/complete/eureka-service/target/eureka-service-0.0.1-SNAPSHOT.jar"
   destination = "/home/adminis/eureka-service-0.0.1-SNAPSHOT.jar"
}

provisioner "file" {
   source = "/var/lib/jenkins/workspace/Eureka_Execution/complete/eureka-client/target/eureka-client-0.0.1-SNAPSHOT.jar"
   destination = "/home/adminis/eureka-client-0.0.1-SNAPSHOT.jar"
}
  
connection {
    type = "ssh"
    user = "adminis"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
  
 provisioner "remote-exec" {   
    inline = [
      "nohup java -jar /home/adminis/eureka-service-0.0.1-SNAPSHOT.jar >> /home/adminis/eureka-service.log &",
      "sleep 100s",
      "nohup java -jar /home/adminis/eureka-client-0.0.1-SNAPSHOT.jar >> /home/adminis/eureka-client.log &"
    ]
  }

}

data "azurerm_public_ip" "eureka_server" {
  name                = "${azurerm_public_ip.publicip.name}"
  resource_group_name = "${azurerm_virtual_machine.eureka_server.resource_group_name}"
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.eureka_server.ip_address}"
}
