output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}


output "random_string" {
  value = random_string.suffix.result
}