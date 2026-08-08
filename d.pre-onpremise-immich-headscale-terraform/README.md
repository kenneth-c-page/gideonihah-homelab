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
