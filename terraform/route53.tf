
data "aws_route53_zone" "route_53_zone_for_our_domain" {
  for_each = local.domain_names_map

  name = each.value.domain
}
