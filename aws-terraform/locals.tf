
locals {
  control_name = "control.example.com"
  node1_name   = "node1.example.com"
  node2_name   = "node2.example.com"

  control_ip = "10.0.1.10"
  node1_ip   = "10.0.2.11"
  node2_ip   = "10.0.2.12"

  node_defs = {
    node1 = { hostname = local.node1_name, ip = local.node1_ip }
    node2 = { hostname = local.node2_name, ip = local.node2_ip }
  }
}
