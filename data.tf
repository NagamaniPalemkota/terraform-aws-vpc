data "aws_availability_zones" "zone_info" {
    state = "available"             #fetches all the available zones inside the region specified in provider.tf
}
data "aws_vpc" "default" {
    default = true #fetches the info. of the vpc , for which default is set as true i.e., default vpc info.
}
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}