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

# Variable for tags 
variable "env" {
  type        = string
  default     = "Dev" 
}
# Variable for tag

variable "owner" {
  type        = string
  default     = "2B"
}
# Variable for tags 
variable "user" {
  type        = string
  default     = "Rootadmin"
}
variable "vm_password" {
  type        = string
  sensitive   = true
}