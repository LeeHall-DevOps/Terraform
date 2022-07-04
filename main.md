# launch a server on aws


# Who is the cloud provider: AWS

# What type is the server? ubuntu 18.04 LTS ami
resource "aws_instance" "Main" {

# size of server: t2-micro
 ami = "ami-0b47105e3d7fc023e"
 instance_type = "t2.micro"

# adding keyname
 key_name = "eng114_group"

# do we need it to have a public access
 associate_public_ip_address = true 

# what do we want to name it
 tags = {
  Name = "Eng114_Lee_terraform_app"
 }

 # Creating VPC here
  resource "aws_vpc" "Main" {                
   cidr_block = var.main_vpc_cidr # Defining the CIDR block use 10.0.0.0/24 for demo
   instance_tenancy = "default"
 }

 # Creating Internet Gateway
 # Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {    
    vpc_id =  aws_vpc.Main.id # vpc_id will be generated after we create VPC
 }

  
 # Create a Public Subnets
 resource "aws_subnet" "publicsubnets" {   
   vpc_id =  aws_vpc.Main.id
   
   # CIDR block of public subnets
   cidr_block = "${var.public_subnets}"        
 }


 # Creating Private Subnets                   
 resource "aws_subnet" "privatesubnets" {
   vpc_id =  aws_vpc.Main.id

   # CIDR block of private subnets
   cidr_block = "${var.private_subnets}"          
 }
 
 # Route table for Public Subnet's
 resource "aws_route_table" "PublicRT" {   
    vpc_id =  aws_vpc.Main.id
         route {

    # Traffic from Public Subnet reaches Internet via Internet Gateway
    cidr_block = "0.0.0.0/0"               
    gateway_id = aws_internet_gateway.IGW.id
     }
 }

 # Route table for Private Subnet's
 resource "aws_route_table" "PrivateRT" {    
   vpc_id = aws_vpc.Main.id
   route {

   # Traffic from Private Subnet reaches Internet via NAT Gateway
   cidr_block = "0.0.0.0/0"            
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
 }
 # Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }
 
 # Route table Association with Private Subnet's
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }
 resource "aws_eip" "nateIP" {
   vpc   = true
 }

 # Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets.id
 }









}


