variable "public_subnet_id" { type = string }
variable "private_subnet_id" { type = string }
variable "sg_control_id" { type = string }
variable "sg_nodes_id" { type = string }

variable "instance_type" { type = string }
variable "ssh_user" { type = string }
variable "key_name" { type = string }

variable "control_name" { type = string }
variable "node_defs" { type = map(object({ hostname = string, ip = string })) }

variable "control_ip" { type = string }
variable "node1_ip" { type = string }
variable "node2_ip" { type = string }

variable "tags" { type = map(string) }
