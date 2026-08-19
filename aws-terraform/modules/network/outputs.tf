output "vpc_id" { value = aws_vpc.lab.id }
output "public_subnet_id" { value = aws_subnet.public_a.id }
output "private_subnet_id" { value = aws_subnet.private_a.id }
output "sg_control_id" { value = aws_security_group.sg_control.id }
output "sg_nodes_id" { value = aws_security_group.sg_nodes.id }
