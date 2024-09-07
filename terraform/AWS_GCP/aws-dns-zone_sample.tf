provider "aws" {
  region = "us-east-1"  # Change to your desired AWS region
}

resource "aws_route53_zone" "iAr_private124_dns" {
  name = "iAr-private124.com"
}

resource "aws_route53_record" "iAr_microsoft_365_mx" {
  zone_id = aws_route53_zone.iAr_private124_dns.zone_id
  name    = "@"
  type    = "MX"
  ttl     = 3600
  records = ["0 pri1.mail.protection.outlook.com.", "10 pri2.mail.protection.outlook.com."]
}

resource "aws_route53_record" "iAr_microsoft_365_txt" {
  zone_id = aws_route53_zone.iAr_private124_dns.zone_id
  name    = "@"
  type    = "TXT"
  ttl     = 3600
  records = ["v=spf1 include:spf.protection.outlook.com -all"]
}

resource "aws_route53_record" "iAr_microsoft_365_autodiscover" {
  zone_id = aws_route53_zone.iAr_private124_dns.zone_id
  name    = "autodiscover"
  type    = "CNAME"
  ttl     = 3600
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "iAr_dmarc" {
  zone_id = aws_route53_zone.iAr_private124_dns.zone_id
  name    = "@"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DMARC1; p=none; rua=mailto:dmarc@example.com"]
}

resource "aws_route53_record" "iAr_dkim" {
  zone_id = aws_route53_zone.iAr_private124_dns.zone_id
  name    = "selector1._domainkey"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DKIM1; k=rsa; p=your_dkim_public_key"]
}

resource "aws_route53_record" "iAr_spf" {
  zone_id = aws_route53_zone.iAr_private124_dns.zone_id
  name    = "@"
  type    = "TXT"
  ttl     = 3600
  records = ["v=spf1 include:spf.protection.outlook.com include:_spf.example.com -all"]
}

resource "aws_route53_record" "iAr_www" {
  zone_id = aws_route53_zone.iAr_private124_dns.zone_id
  name    = "www"
  type    = "A"
  ttl     = 3600
  records = ["192.0.2.1"]  # Change to your web server IP address
}

output "dns_zone_id" {
  value = aws_route53_zone.iAr_private124_dns.zone_id
}
