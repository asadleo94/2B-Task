# Variable for the location of the Resource Group
variable "location" {
  type        = string
  default     = "northeurope"  
}

# Variable for the name of the Resource Group
variable "rg_name" {
  type        = string
  default     = "2B-001"  
}

# Variable for tag 
variable "env" {
  type        = string
  default     = "Dev" 
}

variable "owner" {
  type        = string
  default     = "2B"
}
# Variable for VM User
variable "user" {
  type        = string
  default     = "Rootadmin"
}
variable "vm_password" {
  type        = string
  sensitive   = true
}
