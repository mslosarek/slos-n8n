# Get the Route 53 zone for slos.io
data "aws_route53_zone" "slos" {
  name = "slos.io"
}

# Create A record for n8n.slos.io
resource "aws_route53_record" "n8n" {
  zone_id = data.aws_route53_zone.slos.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.n8n.public_ip]
}
