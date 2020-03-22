output "wp" {
    value = aws_instance.wp.public_ip
}
output "bastion" {
  value = aws_instance.bastion.public_ip
}
output "db" {
  value = aws_instance.db.private_ip
}