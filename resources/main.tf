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

  name   = var.name
  region = var.region
}

module "compute" {
  source = "./modules/compute"

  name       = var.name
  region     = var.region
  subnetwork = module.network.subnet_id
}

module "load_balancing" {
  source = "./modules/lb"

  lb_name        = var.name
  region         = var.region
  vpc_id         = module.network.vpc_id
  subnet_id      = module.network.subnet_id
  instance_group = module.compute.instance_group
}
