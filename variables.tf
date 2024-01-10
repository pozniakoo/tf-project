variable "region" {
  type    = string
  default = "us-east-1"
}

variable "public_subnet_cidrs" {
  type        = string
  description = "Public subnet CIDRs"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  type        = string
  description = "Private Subnet CIDRs"
  default     = "10.0.2.0/24"
}

variable "azs" {
  type        = string
  description = "Availability Zone"
  default     = "us-east-1a"
}

variable "ami" {
  type    = string
  default = "ami-0230bd60aa48260c6"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "access_key" {
  type    = string
  default = "AKIAVL5G6Q7S7IQWA6E4"
}

variable "secret_key" {
  type    = string
  default = "OcTy88dDLZ+9mzanFWQp56bywcb8bw3kckKe3tC0"
}