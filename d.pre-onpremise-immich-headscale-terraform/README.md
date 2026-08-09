Date: 20260808

Create AWS Account
Walk through EC2 setup guide for the credits
- name
- latest ubuntu 26.0.4 LTS HVM, SSD Volume Type
- 64-bit x86
- c7i-flex.large
- create key pair
- create security group, allow ssh, will need update later
- select s3 (for later immich)
- no advanced details
- launch instance 

chmod 400 and ssh -i
install headscale, tailscale; follow headscale then sudo snap install tailscale
open 8080 tcp
Create and associate elastic ip
Edit /etc/headscale/config.yaml => server to ip for now, listener ip 0.0.0.0
sudo systemctl start/restart headscale, sudo systemctl status headscale
sudo headscale users create (user for each device)
GO IN ORDER, DELETE ACCOUNTS ON TAILSCALE FIRST
join from ec2 instance
sudo tailscale up --login-server http://98.80.43.12:8080
copy command from browser

no need sudo, didn't want to deal with it for now

edit ssh rule to the same CIDR subnet that the /etc/headscale/config.yaml contains
Had to update ~/.aws/config, credentials to handle both work and personal profiles

terraform import aws_eip.immich-headscale-via-terraform <existing-allocation-id>
terraform import aws_instance.immich-headscale-via-terraform <existing-instance-id>
aws ec2 describe-security-groups --profile personal --region us-east-1
terraform import aws_security_group.immich-headscale <sg-id>

aws ec2 describe-addresses --profile personal --region us-east-1

terraform plan -out <name>
terraform apply <name>

try ssh-ing through the static ip address then the tailnet ip address

for migration to onpremise hardware: https://ltan.me/post/2024/11/headscalemigrationfromcentos7toubuntu24/

sudo snap install docker

before shutting down tailscale, I added a vpc endpoint rule to terraform and quick created an endpoint in teh same subnet and security group to WebSSH

APT NOT SNAP
# Remove the snap version first
sudo snap remove tailscale

# Install via official apt repo
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update && sudo apt install tailscale