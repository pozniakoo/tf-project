import {
  id = "" #Hosted  zone ID you want to import

  to = aws_route53_zone.r53_zone
}
#run terraform plan -generate-config-out="generated_resources.tf" before terraform apply


resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.adres}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "r53_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.r53_zone.zone_id
}

resource "aws_acm_certificate_validation" "acm-valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.r53_record : record.fqdn]
}

resource "aws_route53_record" "greeting" {
  zone_id = aws_route53_zone.r53_zone.zone_id
  name    = "greeting"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.serverless-app.domain_name
    zone_id                = aws_cloudfront_distribution.serverless-app.hosted_zone_id
    evaluate_target_health = true
  }
}
