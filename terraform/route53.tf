
data "aws_route53_zone" "route_53_zone_for_our_domain" {
  for_each = local.domain_names_map

  name = each.value.domain
}

locals {
  all_domains_and_subdomains_with_zone_id_and_cloudfront_distribution = merge(
    {
      for i, domain_name in local.domain_names_map : domain_name.domain => {
        name = domain_name.domain
        zone_id = [for zone in data.aws_route53_zone.route_53_zone_for_our_domain : zone.zone_id if zone.name == domain_name.domain][0]
        cloudfront_distribution = [for cf_dist in aws_cloudfront_distribution.distribution_redirects : cf_dist if contains(cf_dist.aliases, domain_name.domain)][0]
      }
    },
    {
      for i, sub_domain in local.sub_domains_flattened : "${sub_domain.sub_domain}.${sub_domain.domain_name}" => {
        name = "${sub_domain.sub_domain}.${sub_domain.domain_name}"
        zone_id = [for zone in data.aws_route53_zone.route_53_zone_for_our_domain : zone.zone_id if zone.name == sub_domain.domain_name][0]
        cloudfront_distribution = [for cf_dist in aws_cloudfront_distribution.distribution_redirects : cf_dist if contains(cf_dist.aliases, sub_domain.domain_name)][0]
      }
    }
  )
}

resource "aws_route53_record" "dns_alias_record" {
  for_each = local.all_domains_and_subdomains_with_zone_id_and_cloudfront_distribution

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = "A"

  alias {
    evaluate_target_health = false
    name = each.value.cloudfront_distribution.domain_name
    zone_id = each.value.cloudfront_distribution.hosted_zone_id
  }
}
