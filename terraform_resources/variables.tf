# Location of the resources
variable "location" {
  type = string
}

# Name of the owner
variable "owner_name" {
  type = string
}

# Name of the project
variable "project_name" {
  type = string
}

# List of modules to use
variable "modules_list" {
  type = list
}