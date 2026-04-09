variable "name" {
  description = "The unique name for the resource set"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
}

variable "lb_ip" {
  description = "Load balancer IP address"
  type        = string
}

variable "instance_summary" {
  type        = map(string)
  description = "Map of { name = private_ip } from the compute module"
}

variable "zone" {
  type = string
}
