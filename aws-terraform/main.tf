module "network" {
  source              = "./modules/network"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  az                  = var.az
  tags                = var.tags
}

module "compute" {
  source            = "./modules/compute"
  public_subnet_id  = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id
  sg_control_id     = module.network.sg_control_id
  sg_nodes_id       = module.network.sg_nodes_id

  instance_type = var.instance_type
  ssh_user      = var.ssh_user
  key_name      = var.key_name

  control_name = local.control_name
  node_defs    = local.node_defs

  control_ip = local.control_ip
  node1_ip   = local.node1_ip
  node2_ip   = local.node2_ip

  tags = var.tags
}
