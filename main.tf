provider "aws"{
    region = "us-east-1"
    access_key = "your access key"
    secret_key = "your secret key"
}

module "networking" {
  source       = "../modules/networking"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  public1_cidr = var.public1_cidr
  public2_cidr = var.public2_cidr
  private_cidr = var.private_cidr
}

module "SG" {
  source       = "../modules/SG"
  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
}

module "server" {
  source = "../modules/server"
  project_name = var.project_name
  sg_id  = module.SG.sg_id
}

module "LB" {
  source            = "../modules/LB"
  sg_id             = module.SG.sg_id
  public1_id        = module.networking.public1_id
  public2_id        = module.networking.public2_id
  vpc_id            = module.networking.vpc_id
  project_name = var.project_name
}

module "ASG" {
  source = "../modules/ASG"
  template_id = module.server.template_id
  private_id  = module.networking.private_id
  target_id   = module.LB.target_id
}
