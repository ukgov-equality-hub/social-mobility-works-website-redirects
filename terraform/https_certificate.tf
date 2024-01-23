
resource "aws_acm_certificate" "https_certificate" {
  // This certificate is for use by CloudFront, so it has to be created in the us-east-1 region (for some reason!)
  provider = aws.us-east-1

  for_each = local.domain_names_map

  domain_name = each.value.domain
  subject_alternative_names = [for sub_domain in each.value.sub_domains : "${sub_domain}.${each.value.domain}"]
  validation_method = "DNS"
}

locals {
  dns_records_we_need_to_verify_all_the_domains__list = flatten([
    for https_certificate in aws_acm_certificate.https_certificate : [
      for dvo in https_certificate.domain_validation_options : {
        root_domain = https_certificate.domain_name
        domain_name = dvo.domain_name
        name        = dvo.resource_record_name
        record      = dvo.resource_record_value
        type        = dvo.resource_record_type
        zone_id     = [for zone in data.aws_route53_zone.route_53_zone_for_our_domain : zone.zone_id if zone.name == https_certificate.domain_name][0]
      }
    ]
  ])
  dns_records_we_need_to_verify_all_the_domains__map = {
    for i, record in local.dns_records_we_need_to_verify_all_the_domains__list: record.domain_name => record
  }
}

resource "aws_route53_record" "dns_records_for_https_certificate_verification" {
  for_each = local.dns_records_we_need_to_verify_all_the_domains__map

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "certificate_validation_waiter" {
  // This certificate is for use by CloudFront, so it has to be created in the us-east-1 region (for some reason!)
  provider = aws.us-east-1

  for_each = aws_acm_certificate.https_certificate

  certificate_arn = each.value.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_records_for_https_certificate_verification : record.fqdn if endswith(record.fqdn, each.value.domain_name)]
}
