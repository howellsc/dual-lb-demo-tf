variable "name" {
  description = "MIG name"
  type        = string
}

variable "zone" {
  type = string
}

variable "region" {
  type = string
}

variable "subnetwork" {
  description = "Subnetwork self link"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "compute_instances" {
  description = "Number of VMs"
  type        = number
}
