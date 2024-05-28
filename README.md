# SSH Azure Deployment Script
## Introduction 
This script is a powerful automation tool written in Bash that handles the deployment of a new Ubuntu virtual machine (VM) on Azure and establishes an SSH connection to this VM. It is designed to streamline the workflow and reduce the manual work involved in such a process.

## Prerequisites
 
Before you can use this script, ensure that you have the Azure CLI installed and configured with the appropriate permissions. 

## Script
In its operation, this script performs the following actions:
- It creates a new resource group on Azure with a uniquely generated name.
- It generates a new SSH key pair.
- It creates a new Ubuntu VM in the created resource group and sets up the SSH connection using the generated SSH key pair.

##Security Features

To enhance security, the script performs the following additional actions:

It dynamically retrieves the public IP address of the local machine.
It creates a Network Security Group (NSG) and associates it with the VM.
The NSG contains two rules:
A rule to block all inbound traffic by default.
A rule to allow inbound SSH traffic (port 22) only from the local machine's public IP address.
These security measures ensure that the VM is protected from unauthorized access and that only SSH connections from the specified IP address are allowed.

## Cleanup
if you are playing around with this script many Resource-Groups will be deployed. Use this oneliner to delete all Resource Groups created by the script
```
az group list --query "[?starts_with(name, 'azssh-')].name" -o tsv | xargs -I {} az group delete --name {} --yes --no-wait
```
