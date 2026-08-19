output "control_ssh" {
  description = "SSH command to access control node from your workstation"
  value       = "ssh -i ${path.root}/.generated/lab_key.pem ubuntu@${module.compute.control_public_ip}"
}

output "node1_from_control" {
  description = "SSH command FROM CONTROL NODE to node1 (already configured in ~/.ssh/config)"
  value       = "ssh node1"
}

output "node2_from_control" {
  description = "SSH command FROM CONTROL NODE to node2 (already configured in ~/.ssh/config)"
  value       = "ssh node2"
}

output "control_public_ip" {
  value = module.compute.control_public_ip
}

output "nodes_private_ips" {
  value = module.compute.nodes_private_ips
}