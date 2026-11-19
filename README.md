# Overview

Welcome to my homelab documentation! The goal of this is to learn industry practices and tools while self hosting particular services of interest.

# Technical Layout
## Technologies
| Service | Platform |
|-|-|
| VPN | Tailscale |
| Routing | OpenWrt, Rasbperry Pi 4B |
| PiHole | DietPi, Raspberry Pi 0 2W |
| Switching | 2 Netgear Switches |
| Proxmox | Various |
| VMs | Terraform, Proxmox |
| k3s | Ansible, Debian => NixOS VMs |
| VaultWarden | k3s |
| Immich | k3s |
| SearXNG | k3s |
| NextCloud | k3s |
| Authentik | k3s |
| Exploitation and Hardening Lab | Terraform, Ansible, k3s |

## IaC Implementation
| Service | Path |
|-|-|
| Routing | Briding manually documented, Local router ip, ansible initialize OpenWrt tailscale interface, ip for future ansible runs |
| PiHole | Ansible local ip, tailscale up, use tail ip for future ansible runs, pihole and unbound install and config (credentials and HTTPS), point router to pihole, set pihole as tailnet DNS |
| Switching | Manually document |
| Proxmox | Ansible playbook to plug into terraform during ansible run, maybe cluster? |
| VMs, proxmox | Terraform provision Debian, ansible cluster, ansible go from init to ssh keys |
| k3s | keep as is, use terraform to deprovision debian 1 by 1, spin up nix, k3s configure and cluster new nix |
| k3s | set up proxmox on 1 other machine, provision nix os, cluster as master with ansible |
| k3s | set up nix on raspberry pi, cluster as final HA master with ansible |

# TODO's
- [ ] Get netgear switch models
- [ ] Map subnets and declarative
- [ ] Make network topology