locals {
  resource_name = "${var.project_name}-${var.environment}"
  azs = slice(data.aws_availability_zones.zone_info.names,0,2) #slice function fetches the available zone in index 0, 1 and exclude the index 2 which is mentioned in the endstring.                                                   
}