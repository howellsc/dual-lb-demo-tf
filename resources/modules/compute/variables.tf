variable "name" {
  description = "MIG name"
  type        = string
}

# variable "zone" {
#   type = string
# }

variable "region" {
  type = string
}

variable "subnetwork" {
  description = "Subnetwork self link"
  type        = string
}