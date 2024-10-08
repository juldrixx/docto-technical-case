variable "env" {
  type        = string
  description = "Formatted env. Ex `dev` or `prd`"
}

variable "region" {
  type        = string
  description = "AWS region for the Provider"
}

variable "name" {
  type        = string
  description = "Name of the VPC"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block"
}
