resource "aws_secretsmanager_secret" "secet_manager" {
  name = "${var.secet_manager_name}-${random_string.suffix.id}-${terraform.workspace}"
}


resource "aws_secretsmanager_secret_version" "secret_value" {
  secret_id     = aws_secretsmanager_secret.secet_manager.id
  secret_string = file("ec2keypair")
}



#aws secretsmanager get-secret-value --secret-id <> --query SecretString --output text
