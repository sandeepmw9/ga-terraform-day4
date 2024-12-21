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

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name = aws_key_pair.key.key_name
  security_groups = [aws_security_group.lab4_sg.id]

  tags = {
    Name      = "${var.instance_name}-${terraform.workspace}"
    terraform = true
  }

  connection {
    user        = "ubuntu"
    private_key = tls_private_key.key.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "echo 'hello from terraform provisioned instance' > /usr/share/nginx/index.html",
      "sudo service nginx restart"
     ]
  }

  provisioner "local-exec" {
    command = "echo '${self.public_ip}' > inventory.txt"
  }

}


resource "tls_private_key" "key" {
  algorithm = "RSA"
}

# resource "local_file" "public_key" {
#   filename = "id_rsa.pub"
#   content  = tls_private_key.key.public_key_openssh
# }

resource "local_file" "private_key" {
  filename = "id_rsa.pem"
  content  = tls_private_key.key.private_key_pem

  # provisioner "local-exec" {
  #   command = "chmod 600 id_rsa.pem"
  # }
}

resource "aws_key_pair" "key" {
  key_name = "id_rsa"
  public_key = tls_private_key.key.public_key_openssh
}

