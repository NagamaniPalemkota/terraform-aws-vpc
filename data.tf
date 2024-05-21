data "aws_availability_zones" "zone_info" {
    state = "available"             #fetches all the available zones inside the region specified in provider.tf
}