Date: 2026/08/08-2026/08/09

# Overview

Lately, I've been wanting to branch out a bit more into different technologies and tools used in the industry. I've been itching to assemble my homelab from various pieces of hardware I've acquired, but being caught in the middle of moving houses has made that impractical. At the same time, we're starting to mature a bit more as an organization at the dev team I'm working at, and since our products are becoming more stable, we're targeting the infrastructure, bringing more DevOps into the mix. Between these two, I wanted to gain some experience with Terraform and Ansible. Below is both a write-up/kind-of blog about how I spun up a Headscale server multiple times as I iteratively improved on how I provisioned the infrastructure hosting the server.

The flow will mostly follow sequentially. But, because I want this to be a write-up and a more helpful tutorial than a blog, there will be asides that will detail snaffus I ran into, how I dealt with them, and backtracks I took that would otherwise detract from a more useful write-up.

## Tools and Technologies
- Amazon Web Services Elastic Compute Cloud (EC2), Security Groups (SG), Elastic IP (EIP)
- Terraform
- Ansible
- Headscale
- Docker

# AWS & EC2

1. Create an AWS account. It will want you to create non-root users. For as long as this stays a personal project, that is up to your discretion.
2. At the time of writing this, there was a chance to walk through various onboarding tasks to earn more credits. Do that—it will walk through how to set up an EC2 instance, but on the EC2 dashboard, if you click `Launch Instance` it will walk you through the same wizard:
  - Choose a memorable name for the instance
  - Choose the latest Ubuntu release. At the time of writing, this was Ubuntu 26.0.4 LTS HVM, with SSD Volume Type (also called `resolute`, which will come in handy when we tackle Terraform)
  - Choose 64-bit x86 (also referenced as 64amd in later steps)
  - I chose the c7i-flex.large for the size. Totally overkill, you can probably get away with a t2.micro
  - Create a key pair. After downloading the `.pem` private key, run `sudo chmod 400 <name of key file here>` to make it usable
  - Create a security group. At the very least, leave open port 22 for SSH and also allow TCP over port 8080 for all addresses (this is needed to register devices on your Tailnet)

> [!NOTE]
> Initially, I didn't open port 8080, which made connnecting to the Headscale server much, much harder. Headscale uses the port 8080 to issue the authentication keys that nodes use to register with the server.

  - For choosing other mounted volumes, I did select S3 since I intended to host an Immich server, but that can be done later, as needed
  - Don't need to mess with any of the advanced details for this project
  - Launch instance
3. I prefer being able to SSH in directly from my laptop over using the web shell. To do this, go to the connect tab and find the SSH option. You've already made the key readable, now just run the `ssh -i <path to key> ubuntu@<public ip>` command.
4. Go to the EC2 dashboard, find the `Elastic IPs` on the left tool bar under `Network & Security`, and click `Allocate Elastic IP Address`. After creating it, go back to the EIP dashboard, select the new EIP, click `Actions`, and choose `Associate Elastic IP Address`. Associate it with your new EC2 instance.

# Terraform

Terraform is used for Infrastructure as Code to make managing cloud resources easier and duplicatable. While the scope of this project doesn't necessitate Terraform, it did make setting up a test instance for my Ansible playbook easier, and was really fun to learn how to use.

1. Install Terraform: `homebrew tap hashicorp/tap && brew install hashicorp/tap/terraform`
2. For the next few steps (initializing Terraform, etc.) [Hashicorp has a really helpful tutorial I used](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create). For this project, I ended up using the following to set up the EC2 instance, and as such, used these pages from Hashicorp to piece together how to create my `main.tf`, and later, my `test.tf` (feel free to look at mine, too, to see slight deviations in the application):
> [!NOTE]
> All the `.tf` files are compiled when you run `terraform plan`, which is why `test.tf` is more of a fragment—it's using the same `data` objects that `main.tf` references.

>[!NOTE]
> (This being my first exposure to Terraform), to the extent that this project uses Terraform, there are two objects you will use: data and resource. Data pulls characteristics from your AWS resources and resources can accept the attributes of these data objects and use other attributes you specify. I used this to create a test EC2 instance later in the same VPC, Subnet, and Security Group (and for convenience, the same key) as the EC2 instance that runs the Headscale server.

  - [EC2 Instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
  - [Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
  - [Elastic IP](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)
  - [Key Pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/key_pair)
  - [AMI (the Ubuntu image)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)

> [!TIP]
> If you've already created an EC2 instance, make sure that you use that instance's AMI rather than the ami block, since that will pull whatever is latest. Unless you have everything in place to handle changing infrastructure. At this point, I do not.

> [!TIP]
> When you make the EIP block, you won't need to associate it explicitly with the instance if you include the `instance` line specifying your existing EC2 instance.

> [!TIP]
> If you use the AWS CLI for multiple projects, such as for work, personal projects, or other contributions, you will need to edit the `~/.aws/config` and `~/.aws/credentials` files to include all of them (if you don't want to manually type them in each time). Make sure that the credentials do not include 'profile' like the config is supposed to.

3. For each AWS resource, you'll define an object as `data/resource "type" "identifer you choose"`. In order:
  - Define the provider (aws) and the region and profile (the credentials) you'll be using
  - Use the default (or otherwise specify another VPC by its id or other characteristics)
  - Define the subnet you'll use
  - Create a security group with the specified VPC's id
  - Create rules and define their security group's id (this attaches the rules to the security group)
  - Define which AMI you'll be using
  - Define the key pair you'll be using
  - Create an EC2 instance referencing all the data objects and resources (security group and rules) from above. You'll notice that when you use attributes from resources, those get pulled using the identifiers (resource type + your identifier in the resource/data line), whereas attributes from data objects get pulled using the `data.` prefix.
  - Create the EIP and define its instance as the one you defined above.
4. If you want this Terraform file to create new EC2 instances, great! It would work just fine. But if you want Terraform to manage your current AWS resources, you'll need to specify that these objects refer to pre-existing resources. This is done by importing the resources you already have:
  - Get the EIP allocation id: `aws ec2 describe-addresses --profile personal --region <your region>`
  - Import the EIP: `terraform import aws_eip.<EIP name> <allocation id>`
  - Import the EC2 instance (id can be found in the EIP description): `terraform import aws_instance.<instance name> <instance id>`
  - Get the security group and its rules IDs: `aws ec2 describe-security-groups --profile personal --region <your region>`. It will be really long, but you can find the rule IDs from the JSON it outputs.
  - Import the security group and its rules by ids:
  `terraform import aws_vpc_security_group.<sg name> <sg id>` 
  and 
  `terraform import aws_vpc_security_group_<egress/ingress>_rule.<rule name> <rule id>`.
5. Run `terraform plan -out=<plan name here>`. Just as when you make any changes between applying plans, it will show you discrepancies between the resources managed by the plan (the ones we're importing now) and what's described by the plan. Fix any discrepancies now these may include changes (highlighted in yellow) or deletions (highlighted in red). Changes or deletions will often be because of AMI or identifier mismatches.
6. Run `terraform apply <plan name here>`.

# Docker and Headscale

> [!NOTE]
> When I first started this, I got Headscale running THEN moved it to docker. If that's the case, run `sudo systemctl stop headscale && sudo systemctl disable headscale` and then move it over into the Docker container.

1. Install docker, start it and enable it: `sudo snap install docker`, `sudo systemctl start docker`, `sudo systemctl enable docker`
2. Looking at the `docker-compose` in the `ansible/d.files` directory, you'll notice a couple of things:
  - Port 8080 is mapped to the host's port 8080. That is so we can still use the EC2's EIP to register with the Headscale server.
  - We mount two volumes to the container's `/etc/headscale` and `/var/lib/headscale` directories—these are where we will store the `config.yaml` file (also in `ansible/d.files`), and where the Headscale server will store the databases and other files to run (this will give us persistence if we decide to move the server to a different machine—we can just copy these files over to the same directory).
  - These directories are in a `headscale` directory I created in the user's home directory (not best practice, but I planned on moving this over to my own hardware relatively soon), andrequire a `config` and `lib` directory in that `headscale` directory. Create those now.
3. Copy the `config.yaml` to the `config` directory you just created and the `docker-compose.yml` to the `headscale` directory. Edit the server address to be your EIP and the listener address to be `0.0.0.0/0` so you can register devices from any IP range.
4. Inside the `headscale` directory, run `sudo docker compose up -d`.
5. Make sure the server is running properly:
  - `sudo docker ps`
  - `sudo docker logs --follow headscale`
  - `curl http://<EIP or your own domain name here, if you set that up>:8080/health`. This should return {"status":"pass"}
6. Create a single user for all the devices you'll connect (I ran into issues connecting to other devices on the tailnet when I had them put under their own user): `sudo docker compose exec headscale headscale users create <user name here> && sudo docker compose exec headscale headscale users list`

Congratulations! You now have a Headscale server running that you can use to manage your Tailnet.

# Ansible

> [!NOTE]
> Even though I just had to install `docker` and `tailscale` to run the Headscale server and connect to it, the prerequisites help maintain idempotence, since they may not be installed on your system. Similarly, `docker` is provided by community contributions to ansible, which is why there is the community annotation for the build task at the end, and the two install tasks.

1. Install Ansible. I use Mac, so I just ran `homebrew install ansible`
2. Build an inventory. While I preferred using the `.yml` format for the inventory, they recommend using `.ini`. I created both.
3. Verify and ping the hosts in your inventory:
  - `ansible-inventory -i inventory.yml --list`
  - `ansible myhosts -m ping -i inventory.yml`
4. As seen in the `inventory.yml` in `ansible`, you can specify the user and key so later executions can be run seamlessly.
5. Create a playbook for whichever group of hosts you want. I have two groups - one for the original EC2 instance, and the other for a test group.
6. Write a block for each of the actions (feel free to pull up the `playbook.yml` to follow along and to make sense of Ansible generally):

  - [Creating a playbook](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
  - [Install packages: ca-certificaates, curl, gnupg, and sqlite (for Headscale server and to curl the Tailscale repo and GPG key), docker.io (engine), docker-compose-v2 (compose plugin)](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
  - [Download the Tailscale GPG key and repo](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html)
  - [And the ubuntu user to the docker group](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html)
  - [Start and enable Docker and tailscaled](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_service_module.html)
  - [Create the directories for the Headscale server (`headscale`, `config`, and `lib`); give them the correct permissions](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html)
  - [Copy the `config` and `docker-compose` files from this repository ](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)
  - [Install the community docker collection to run the docker build task](https://docs.ansible.com/ansible/latest/collections_guide/collections_installing.html)
  - [Bring up the headscale container](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_v2_module.html)

7. Before running, test by following the directions in `Testing` below.

## Testing

1. To test, write another Terraform file similar to main, but this time just creating a new EC2 instance and EIP associated to the new EC2 instance's id (take a look at `test.tf`). Make sure they use different names than what the original instance and EIP use. I used the same key pair for convenience.
2. I used the same command from earlier to find the new instance and its EIP: `aws ec2 describe-addresses --profile personal --region <your region>`.
3. Add a host (and group of hosts that contains just this EC2 instance) in `inventory.yml`.
4. Change `playbook.yml` to target this new group of hosts.
5. Run with `ansible-playbook -i inventory.yml playbook.yml`. Everything should be marked `ok` or `changed` (something that wasn't present on the machine before). Run again to make sure that everything results in `ok` (no changes, and thus, idempotent).
6. Take down the testing EC2 instance and EIP (to avoid unnecessary costs) with: `terraform destroy -target=aws_instance.<instance identifier you chose in test.tf> -target=aws_eip.<EIP identifier you chose in test.tf>`

# Tailscale

> [!WARNING]
> When I first went about this, I installed Tailscale via snap. This gave me tons of issues connecting to the EC2 instance that was running the Headscale server via SSH, so if this is what happened to you, it will probably be best to `sudo snap remove tailscale` and follow the instructions below`

1. Install the official Tailscale repo for apt:

`curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg`

`curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list`

`sudo apt update && sudo apt install tailscale`

2. If you already had devices connected to another tailnet, delete that account, and login again, selecting 'Use a custom coordination server'.
3. To connect to the Headscale server, run: `sudo tailscale up --login-server=http://<EIP or domain name>:8080`. If you're setting up headless, open the link it yields in a browser elsewhere.
4. Run the command displayed by opening up the link from the previous command on the Headscale server (from the `headscale` directory on the EC2 instance): `sudo docker compose exec headscale <command here>`.

> [!TIP]
> Join the tailnet from the EC2 instance hosting the Headscale server. It makes managing the server easier.

> [!TIP]
> If you have any issues connecting to other devices on your tailnet, a useful command to take down and force restart the connection to the tailnet is: `sudo tailscale down && sudo tailscale up --reset --login-server=http://<EIP or domain name>:8080 --accept-routes`

# Immich?

Initially I wanted to mount an S3 bucket to the EC2 instance and host an Immich server. Hence why I used docker to host the Headscale server—I planned on migrating both to my own hardware after I move. However, due to time constraints, Immich may have to wait for later.