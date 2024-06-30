# SSH Azure Deployment Script
## Introduction 
This script is a powerful automation written in Bash or powershell that handles a quick and dirty but secure deployment of a new Ubuntu virtual machine (VM) on Azure and establishes an SSH connection to this VM.

```

             ______  _    _   _____    ______              __      __  __  __                _____    _____   _    _                _____    ____    _   _   _   _   ______    _____   _______ 
     /\     |___  / | |  | | |  __ \  |  ____|      _      \ \    / / |  \/  |      _       / ____|  / ____| | |  | |      _       / ____|  / __ \  | \ | | | \ | | |  ____|  / ____| |__   __|
    /  \       / /  | |  | | | |__) | | |__       _| |_     \ \  / /  | \  / |    _| |_    | (___   | (___   | |__| |    _| |_    | |      | |  | | |  \| | |  \| | | |__    | |         | |   
   / /\ \     / /   | |  | | |  _  /  |  __|     |_   _|     \ \/ /   | |\/| |   |_   _|    \___ \   \___ \  |  __  |   |_   _|   | |      | |  | | | . ` | | . ` | |  __|   | |         | |   
  / ____ \   / /__  | |__| | | | \ \  | |____      |_|        \  /    | |  | |     |_|      ____) |  ____) | | |  | |     |_|     | |____  | |__| | | |\  | | |\  | | |____  | |____     | |   
 /_/    \_\ /_____|  \____/  |_|  \_\ |______|                 \/     |_|  |_|             |_____/  |_____/  |_|  |_|              \_____|  \____/  |_| \_| |_| \_| |______|  \_____|    |_|   
                                                                                                                                                                                               
```                                                                                                                                                                                               
           
                                                                                                                                                                           

## Prerequisites
Before you can use this script, ensure that you have the Azure CLI installed and configured with the appropriate permissions. 

## How to Use
### Bash
```
az login --use-device-code && git clone https://github.com/crtvrffnrt/azsshconnect.git && chmod +x ./azsshconnect/azsshconnect.sh && ./azsshconnect/azsshconnect.sh
```

## Script
In its operation, this script performs the following actions:
- It creates a new resource group on Azure with a uniquely generated name.
- It generates a new SSH key pair.
- It creates a new Ubuntu VM in the created resource group and sets up the SSH connection using the generated SSH key pair.
- Following Resources will be created:
![image](https://github.com/crtvrffnrt/azsshconnect/assets/115865719/da04abdc-27bf-414c-9bab-151fb11c7f29)

## `--do-not-delete` Flag

### Overview

The `--do-not-delete` flag is an optional argument for the deployment script. When this flag is provided, the script will skip the step of deleting old resource groups that were previously created by the script. This can be useful if you want to retain the older resource groups for any reason, such as debugging or auditing.

### Usage

To use the `--do-not-delete` flag, simply add it to the command when executing the script:

```sh
./deploy_azure_vm.sh --do-not-delete
```
## Security Features
To enhance security, the script performs the following additional actions:

- It dynamically retrieves the public IP address of the local machine.
- It creates a Network Security Group (NSG) and associates it with the VM.
- The NSG contains two rules:
- A rule to block all inbound traffic by default.
- A rule to allow inbound SSH traffic (port 22) only from the local machine's public IP address.
- These security measures ensure that the VM is protected from unauthorized access and that only SSH connections from the specified IP address are allowed.

## Cleanup
if you are playing around with this script many Resource-Groups will be deployed. Use this oneliner to delete all Resource Groups created by the script
```
az group list --query "[?starts_with(name, 'azssh-')].name" -o tsv | xargs -I {} az group delete --name {} --yes --no-wait
```
