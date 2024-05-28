# SSH Azure Deployment Script
 
This script is a powerful automation tool written in Bash that handles the deployment of a new Ubuntu virtual machine (VM) on Azure and establishes an SSH connection to this VM. It is designed to streamline the workflow and reduce the manual work involved in such a process.

Prerequisites
 
Before you can use this script, ensure that you have the Azure CLI installed and configured with the appropriate permissions. 
 
In its operation, this script performs the following actions:
- It creates a new resource group on Azure with a uniquely generated name.
- It generates a new SSH key pair.
- It creates a new Ubuntu VM in the created resource group and sets up the SSH connection using the generated SSH key pair.

if you are playing around with this script many Resource-Groups will be deployed. Use this oneliner to delete all Resource Groups created by the script
```
az group list --query "[?starts_with(name, '171')].name" -o tsv | xargs -I {} az group delete --name {} --yes --no-wait
```
