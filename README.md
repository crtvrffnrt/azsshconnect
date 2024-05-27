# SSH Tunnel Azure Deployment Script
 
This script is a powerful automation tool written in Bash that handles the deployment of a new Ubuntu virtual machine (VM) on Azure and establishes an SSH tunnel to this VM. It is designed to streamline the workflow and reduce the manual work involved in such a process.
Prerequisites
 
Before you can use this script, ensure that you have the Azure CLI installed and configured with the appropriate permissions. Also, an SSH client is necessary to establish a connection with the VM.
How to Use
 
Follow the steps below to use the SSH Tunnel Azure Deployment Script:
Clone this repository.
Navigate to the directory where the script is located.
Make the script executable.
Run the script.

In its operation, this script performs the following actions:
- It creates a new resource group on Azure with a uniquely generated name.
- It generates a new SSH key pair.
- It creates a new Ubuntu VM in the created resource group and sets up the SSH connection using the generated SSH key pair.
- It retrieves the public IP address of the VM and establishes an SSH connection using the private key from the key pair generated earlier.
