output "control_public_ip" {
  value = aws_instance.control.public_ip
}

output "nodes_private_ips" {
  value = { for k, i in aws_instance.nodes : k => i.private_ip }
}
