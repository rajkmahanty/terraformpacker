##### AZURE section start

#variable "client_id" {ca9d7487-c484-49a2-b7a0-4b0a4cf12d9b}
#variable "client_secret" {bcc0f396-5a5e-4231-a951-c7e8677f7933}
#variable "tenant_id" {2c1f8453-5cc2-44f7-a93f-49ab55dcaab8}
#variable "subscription_id" {3216b735-086e-46b2-9363-44095f8213e1}

variable "client_id" { default = "6ba8dafc-eadd-4388-a4c3-0fdcb564a950" }
variable "client_secret" { default = "6ba8dafc-eadd-4388-a4c3-0fdcb564a950" }
variable "tenant_id" { default = "027e173a-9063-4df7-9aea-b38a90e8db3a" }
variable "subscription_id" { default = "5e4c5a35-8adf-4cb9-89f8-6ab8f53068e0" }

variable "computer_name" {
  description = "Machine_name"
  default = "eureka-server"
}

variable "admin_username" {
  description = "Machine_user_name"
  default = "devops"
}

variable "admin_password" {
  description = "Machine_password"
  default = "Welcome1"
}

variable "resource_group" {
  description = "Resource Group"
  default = "rajazureops"
}

variable "vm_size" {
  description = "Virtual Machine size"
  default = "Standard_D2s_v3"
}

###### AZURE section end






