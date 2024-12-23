data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "local_file" "ec2keypair" {
  filename = "ec2keypair"
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2keypair.key_name
  security_groups             = [aws_security_group.lab4_sg.id]

  tags = {
    Name      = "${var.instance_name}-${random_string.suffix.id}-${terraform.workspace}"
    terraform = true
  }

  connection {
    user        = "ubuntu"
    private_key = data.local_file.ec2keypair.content
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = "echo '${self.public_ip}' > inventory.txt"
  }

  provisioner "file" {
    source      = "apache.yaml"
    destination = "/tmp/apache.yaml"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install ansible -y",
      "sudo ansible-playbook -u=ubuntu -c=local -i localhost, /tmp/apache.yaml"
    ]
  }

}


# resource "tls_private_key" "key" {
#   algorithm = "RSA"
# }

# resource "local_file" "public_key" {
#   filename = "id_rsa.pub"
#   content  = tls_private_key.key.public_key_openssh
# }

# resource "local_file" "private_key" {
#   filename = "id_rsa.pem"
#   content  = tls_private_key.key.private_key_pem

#   # provisioner "local-exec" {
#   #   command = "chmod 600 id_rsa.pem"
#   # }
# }

resource "aws_key_pair" "ec2keypair" {
  key_name   = "ec2keypair"
  public_key = file("ec2keypair.pub")
}

