resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hosts
  tags = merge (
      var.common_tags,var.vpc_tags,
      {
        Name = local.resource_name
      }
    )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,var.igw_tags,
    {
      Name = local.resource_name
    }
  )
}
#public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.azs[count.index]
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true # should be set true explicitly for public subnet
  tags = merge(
    var.common_tags,
    var.public_subnet_cidr_tags,
    {
      Name = "${local.resource_name}-public-${local.azs[count.index]}"
    }
  )
}
# private subnets
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  count = length(var.private_subnet_cidrs)
  availability_zone = local.azs[count.index] #specifies the availability zone for this subnet
  cidr_block = var.private_subnet_cidrs[count.index]
  tags = merge(
    var.common_tags,
    var.private_subnet_cidr_tags,
    {
      Name = "${local.resource_name}-private-${local.azs[count.index]}"
    }
  )
}

#database subnets
resource "aws_subnet" "database" {
  vpc_id = aws_vpc.main.id
  availability_zone = local.azs[count.index]
  count = length (var.database_subnet_cidrs)
  cidr_block = var.database_subnet_cidrs[count.index]
  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.resource_name}-database-${local.azs[count.index]}"
    }
  )
}
#elastic ipaddress creation
resource "aws_eip" "elastic_address" {
  domain   = "vpc"
}
#NAT gateway creation
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic_address.id
  subnet_id     = aws_subnet.public[0].id #nat has to be associated with public subnet.we're creating only one nat since, it is billable
  tags = merge(
    var.common_tags,
    var.nat_tags,
    {
      Name = "${local.resource_name}"
    }
  )
  
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#public route table creation
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
      Name = "${local.resource_name}-public"
    }
  )
}

#private route table creation
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
      Name = "${local.resource_name}-private"
    }
  )
}

#database route table creation
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
      Name = "${local.resource_name}-database"
    }
  )
}

#aws public route creation for public route table
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

#aws private route creation for private route table
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

#aws database route creation for database route table
resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# public route table associations to subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}
# private route table associations to subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}
# database route table associations to subnets
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}