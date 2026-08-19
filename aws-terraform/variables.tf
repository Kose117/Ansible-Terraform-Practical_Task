variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "az" {
  description = "Availability Zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR notation to allow SSH (e.g., 200.25.1.2/32)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_user" {
  description = "Default SSH username (ubuntu for Ubuntu AMIs)"
  type        = string
  default     = "ubuntu"
}

variable "key_name" {
  description = "Key pair name to register in AWS"
  type        = string
  default     = "ansible-lab-key"
}

variable "tags" {
  type    = map(string)
  default = { Project = "ansible-lab", Owner = "jose", Env = "dev" }
}


