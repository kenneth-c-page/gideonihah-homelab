provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "immich-headscale" {
  name        = "launch-wizard-1"
  description = "launch-wizard-1 created 2026-08-08T14:39:23.790Z" 
  vpc_id      = data.aws_vpc.default.id

  tags = {
    name        = "launch-wizard-1"
    description = "launch-wizard-1 created 2026-08-08T14:39:23.790Z" 
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_security_group.immich-headscale.id
  cidr_ipv4         = "100.64.0.0/10"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow-private-vpc-ssh" {
  security_group_id = aws_security_group.immich-headscale.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow-headscale-auth" {
  security_group_id = aws_security_group.immich-headscale.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.immich-headscale.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.immich-headscale.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_key_pair" "existing" {
  key_name = "pre-homelab-immich-headscale"
}

resource "aws_instance" "immich-headscale-via-terraform" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "c7i-flex.large"
  subnet_id              = "subnet-01b51bdfb5a4b3dda"
  vpc_security_group_ids = [aws_security_group.immich-headscale.id]
  key_name               = "pre-homelab-immich-headscale"

  tags = {
    Name = "homelab-backup"
  }
}

resource "aws_eip" "immich-headscale-via-terraform" {
  domain                    = "vpc"
  instance                  = aws_instance.immich-headscale-via-terraform.id
}