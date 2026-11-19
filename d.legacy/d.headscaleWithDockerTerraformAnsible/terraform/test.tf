resource "aws_instance" "ansible-test-instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = "subnet-01b51bdfb5a4b3dda"
  vpc_security_group_ids = [aws_security_group.immich-headscale.id]
  key_name               = "pre-homelab-immich-headscale"

  tags = {
    Name = "ansible-test"
  }
}

resource "aws_eip" "ansible-test-eip" {
  domain                    = "vpc"
  instance                  = aws_instance.ansible-test-instance.id
}