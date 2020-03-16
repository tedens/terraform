output "pub_ec2" {
    value = aws_instance.pub.public_ip
}
output "priv_ec2" {
  value = aws_instance.priv.private_ip
}