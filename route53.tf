/*import {
  id = "Z019066632IEA3I2FVO57"

  to = aws_route53_zone.r53_zone
}
*/
#terraform plan -generate-config-out=generated_resources.tf

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

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.r53_record : record.fqdn]
}

resource "aws_route53_record" "greeting" {
  zone_id = aws_route53_zone.r53_zone.zone_id
  name    = "greeting"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}