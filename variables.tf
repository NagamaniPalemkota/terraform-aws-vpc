## VPC variables
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}
variable "enable_dns_hosts" {
    type = bool
    default = true
}
variable "vpc_tags"{
    type = map
    default = {

    }
}
## Project variables
variable "project_name" {
    type = string
}
variable "environment"{
    type = string
    default = "dev"
}
variable "common_tags"{
    type = map 
}
## igw tags
variable "igw_tags"{
    type = map
    default = {
    }  
    }

##Public subnet vars
variable "public_subnet_cidrs"{
    type = list 
    validation {
        condition = length (var.public_subnet_cidrs) == 2
        error_message = "Enter 2 valid public subnet cidr ranges"
    }
}
variable "public_subnet_cidr_tags" {
    type = map 
    default = {

    }
}
#private subnet vars
variable "private_subnet_cidrs"{
    type = list 
    validation{
        condition = length (var.private_subnet_cidrs) == 2
        error_message = "Please enter 2 valid private subnet cidr ranges"
    }
}
variable "private_subnet_cidr_tags" {
    type = map 
    default = {

    }
}
#database subnet vars
variable "database_subnet_cidrs" {
    type = list 
    validation{
        condition = length(var.database_subnet_cidrs) == 2
        error_message = "Please enter 2 valid cidr ranges for database subnet "
    }
}
variable "database_subnet_tags" {
    type = map 
    default = {

    }
}
variable "database_subnet_group_tags" {
    type = map 
    default = {

    }
}
#nat tags
variable "nat_tags" {
    type = map 
    default = {

    }
}
#public route table tags
variable "public_route_table_tags" {
    type = map 
    default = {
        
    }
}
#private route table tags
variable "private_route_table_tags" {
    type = map 
    default = {
        
    }
}
#database route table tags
variable "database_route_table_tags" {
    type = map 
    default = {
        
    }
}

#peering variables
variable "is_peering_required" {
    type = bool
    default = false
}
variable "peer_vpc_id" {
    type = string
    default = ""
}
variable "peering_tags" {
    type = map
    default = {}
}