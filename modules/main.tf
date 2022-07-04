# launch a server on aws

# who is the cloud provider AWS
provider "aws" {

# where do you want to create resources eu-west-1
  region = "eu-west-1"
}
################################# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "${var.infra_env}-vpc"
    Environment = var.infra_env
  }
}

################################# PUBLIC SUBNET
resource "aws_subnet" "public" {
  for_each = var.public_subnet_numbers

  vpc_id = aws_vpc.vpc.id

  // 10.80.0.0/16
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    Name = "${var.infra_env}-public-subnet"
    Environment = var.infra_env
    Subnet = "${each.key}-${each.value}"
  }
}

################################# PRIVATE SUBNET
resource "aws_subnet" "private" {
  for_each = var.private_subnet_numbers

  vpc_id = aws_vpc.vpc.id

  // 10.80.0.0/16 
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)
  
  tags = {
    Name = "${var.infra_env}-private-subnet"
    Environment = var.infra_env
    Subnet = "${each.key}-${each.value}"
  }
}

################################# INTERNET GATEWAY
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.infra_env}-igw"
  }
}

################################# ROUTE TABLE
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.infra_env}-route-table" 
  }
}

################################# ROUTE FROM (PUBLIC)
resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.public["eu-west-1a"].id
}

resource "aws_security_group" "allow_nginx" {
  name = "allow_nginx"
  description = "Allow port 80"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_nginx"
  }
}

# what type server - ubuntu 18.04 LTS ami
resource "aws_instance" "app_instance" {

    # size of the server - t2.micro
    ami = "ami-078ec35f07d5b1ae8"
    instance_type = "t2.micro"
    key_name = "eng114_group"
    # do we need it to have a public access
    associate_public_ip_address = true
    # These two automatically go to default settings
    # subnet_id = only use if you want to use customs or one you made 
    # vpc_security_group_ids = only use if you want to use customs or one you made
    
    # what do we want to name it
    tags = {
        Name = "eng114_lee_terraform_app"   
    }
}

# what type server - ubuntu 18.04 LTS ami
resource "aws_instance" "db_instance" {

    # size of the server - t2.micro
    ami = "ami-0dfc8089308f58519"
    instance_type = "t2.micro"
    key_name = "eng114_group"
    # do we need it to have a public access
    associate_public_ip_address = false
    # These two automatically go to default settings
    # subnet_id = only use if you want to use customs or one you made 
    # vpc_security_group_ids = only use if you want to use customs or one you made
    
    # what do we want to name it
    tags = {
        Name = "eng114_lee_terraform_db"   
    }
}