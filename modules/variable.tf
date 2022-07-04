variable "infra_env" {
  type        = string
  description = "eng114_lee_terraform"
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.80.0.0/16"
}

variable "public_subnet_numbers" {
  type        = map(number)
  description = "Map of AZ to a number that should be used for public subnets"
  default = {
    "eu-west-1a" = 1
    "eu-west-1b" = 2
    "eu-west-1c" = 3
  }
}

variable "private_subnet_numbers" {
  type        = map(number)
  description = "Map of AZ to a number that should be used for private subnets"
  default = {
    "eu-west-1a" = 4
    "eu-west-1b" = 5
    "eu-west-1c" = 6
  }
}
