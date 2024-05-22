resource "aws_vpc_peering_connection" "peer_conn" {
    count = var.is_peering_required ? 1 : 0
    vpc_id        = aws_vpc.main.id #requester vpc id
    peer_vpc_id   =  var.peer_vpc_id == "" ? data.aws_vpc.default.id   : var.peer_vpc_id  #acceptor vpc id, if user did not give value, it'll consider default vpc, else given by him
    auto_accept = var.peer_vpc_id == "" ? true : false
    tags = merge(
        var.common_tags,
        var.peering_tags,
        {
            Name ="${local.resource_name}" 
        }
    )
}

#count is used to avoid the creation of vpc peering and route table creation for peering, when peering is not required
#aws public route creation for peering with default vpc
resource "aws_route" "public_peering" {
    count = var.is_peering_required && var.peer_vpc_id == "" ? 1 : 0
    route_table_id            = aws_route_table.public.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_conn[count.index].id
}

#aws private route creation for peering with default vpc
resource "aws_route" "private_peering" {
    count = var.is_peering_required && var.peer_vpc_id == "" ? 1 : 0
    route_table_id            = aws_route_table.private.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_conn[count.index].id
}

#aws database route creation for peering with default vpc
resource "aws_route" "database_peering" {
    count = var.is_peering_required && var.peer_vpc_id == "" ? 1 : 0
    route_table_id            = aws_route_table.database.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_conn[count.index].id
}

#aws default VPC - route creation for peering with expense vpc
resource "aws_route" "acceptor_peering" {
    count = var.is_peering_required && var.peer_vpc_id == "" ? 1 : 0
    route_table_id            = data.aws_vpc.default.main_route_table_id
    destination_cidr_block    = aws_vpc.main.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_conn[count.index].id
}