
locals {
  config_file_text = file("${path.module}/configure_the_redirects.json")
  config = jsondecode(local.config_file_text)

  redirects_config_file_text = file("${path.module}/configure_the_redirects.csv")
  redirects_config = csvdecode(local.redirects_config_file_text)

  // When you save a CSV file in Excel, the file starts with a ZWNBSP character.
  // The csvdecode function doesn't parse this correctly, so thinks that the first field is called "[ZWNBSP]from" instead of "from"
  // So, I've just added a pointless empty column on the from of the CSV file
  // Then, we use this code to just select the columns we want to pass through to the Lambda javascript code
  redirects_config_just_the_fields_we_want = [
    for redirect in local.redirects_config : {
      case_sensitive = (redirect.case_sensitive == "TRUE")
      from = redirect.from
      to = redirect.to
    }
  ]
  redirects_json_text = jsonencode(local.redirects_config_just_the_fields_we_want)

  domain_names_map = {
    for i, domain_name in local.config.domain_names: domain_name.domain => {
      domain = domain_name.domain
      sub_domains = domain_name.sub_domains
    }
  }

  sub_domains_flattened = flatten([
    for domain_name in local.config.domain_names : [
      for sub_domain in domain_name.sub_domains : {
        domain_name = domain_name.domain
        sub_domain = sub_domain
      }
    ]
  ])

  redirect_everything_else_to = local.config.redirect_everything_else_to
}
