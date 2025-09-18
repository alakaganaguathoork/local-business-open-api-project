output "public_ips" {
  value = {
    for key, value in aws_instance.main :
    key => value.public_ip
  }
}

output "dns_names" {
  value = aws_alb.alb.dns_name
}