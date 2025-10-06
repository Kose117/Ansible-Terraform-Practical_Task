terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws   = { source = "hashicorp/aws", version = ">= 5.0" }
    tls   = { source = "hashicorp/tls", version = ">= 4.0" }
    http  = { source = "hashicorp/http", version = ">= 3.4.0" }
    local = { source = "hashicorp/local", version = ">= 2.4.0" }
    null  = { source = "hashicorp/null", version = ">= 3.2.0" }
  }
}

provider "aws" {
  region = var.region
}