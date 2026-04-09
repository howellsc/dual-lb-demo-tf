locals {
  vm_count = 2
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  # backend "gcs" {
  #   bucket = "terraform-state"
  #   prefix = "terraform/tfstate"
  # }
  backend "local" {}
}

module "network" {
  source = "./modules/network"

  name             = var.name
  region           = var.region
  lb_ip            = module.load_balancing.lb_ip
  zone             = var.zone
  instance_summary = module.compute.instance_summary
}

module "compute" {
  source = "./modules/compute"

  name              = var.name
  region            = var.region
  vpc_id            = module.network.vpc_id
  subnetwork        = module.network.subnet_id
  zone              = var.zone
  compute_instances = local.vm_count
}

module "load_balancing" {
  source = "./modules/lb"

  lb_name   = var.name
  region    = var.region
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnet_id
  l4_neg    = module.network.l4_neg
  l7_neg    = module.network.l7_neg
}
