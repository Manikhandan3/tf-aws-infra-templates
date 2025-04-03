resource "aws_route53_record" "app_domain" {
  count   = var.vpc_count
  zone_id = var.route53_zone_id
  name    = "${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb[count.index].dns_name
    zone_id                = aws_lb.app_lb[count.index].zone_id
    evaluate_target_health = true
  }
}