

resource "aws_route53_record" "alb_dns_record" {
  zone_id = "Z10299161M47DBD68JOWT"
  name    = aws_s3_bucket.my_bucket.id
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.alb.dns_name]
}
