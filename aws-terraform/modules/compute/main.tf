data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Asegura la carpeta .generated ANTES
resource "null_resource" "ensure_generated_dir" {
  provisioner "local-exec" {
    command     = "mkdir -p ${path.root}/.generated"
    interpreter = ["/bin/bash", "-c"]
  }
}

# Genera la clave SSH para conectarse desde tu workstation
resource "tls_private_key" "lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Guarda la clave privada localmente
resource "local_file" "lab_private_key" {
  content         = tls_private_key.lab_key.private_key_pem
  filename        = "${path.root}/.generated/lab_key.pem"
  file_permission = "0600"
  depends_on      = [null_resource.ensure_generated_dir]
}

# Registra la clave pública en AWS
resource "aws_key_pair" "lab_key" {
  key_name   = var.key_name
  public_key = tls_private_key.lab_key.public_key_openssh
}

# Clave ED25519 interna para que control haga SSH a los nodos
resource "tls_private_key" "ansible_key" {
  algorithm = "ED25519"
}

resource "aws_instance" "control" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.lab_key.key_name
  subnet_id                   = var.public_subnet_id
  private_ip                  = var.control_ip
  vpc_security_group_ids      = [var.sg_control_id]
  
  user_data = templatefile("${path.root}/templates/cloud-init-control.sh.tftpl", {
    hostname        = var.control_name
    control_ip      = var.control_ip
    node1_ip        = var.node1_ip
    node2_ip        = var.node2_ip
    node1_name      = var.node_defs.node1.hostname
    node2_name      = var.node_defs.node2.hostname
    private_key_pem = tls_private_key.ansible_key.private_key_openssh
    ssh_user        = var.ssh_user
  })
  
  associate_public_ip_address = true

  root_block_device { 
    volume_size = 10
    volume_type = "gp3" 
  }

  tags = merge(var.tags, { Name = var.control_name, Role = "control" })
  
  depends_on = [local_file.lab_private_key]
}

resource "aws_instance" "nodes" {
  for_each = var.node_defs

  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.lab_key.key_name
  subnet_id                   = var.private_subnet_id
  private_ip                  = each.value.ip
  vpc_security_group_ids      = [var.sg_nodes_id]
  
  user_data = templatefile("${path.root}/templates/cloud-init-node.sh.tftpl", {
    hostname     = each.value.hostname
    control_ip   = var.control_ip
    node1_ip     = var.node1_ip
    node2_ip     = var.node2_ip
    control_name = var.control_name
    node1_name   = var.node_defs.node1.hostname
    node2_name   = var.node_defs.node2.hostname
  })
  
  associate_public_ip_address = false

  root_block_device { 
    volume_size = 10
    volume_type = "gp3" 
  }

  tags = merge(var.tags, { Name = each.value.hostname, Role = "node" })
}