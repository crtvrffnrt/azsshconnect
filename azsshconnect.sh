#!/bin/bash

# Function to display messages with colors
display_message() {
    local message="$1"
    local color="$2"
    case $color in
        red) echo -e "\033[91m${message}\033[0m" ;;
        green) echo -e "\033[92m${message}\033[0m" ;;
        yellow) echo -e "\033[93m${message}\033[0m" ;;
        blue) echo -e "\033[94m${message}\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# Check Azure authentication
check_azure_authentication() {
    az account show &> /dev/null
    if [ $? -ne 0 ]; then
        display_message "Please authenticate to your Azure account using 'az login --use-device-code'." "red"
        exit 1
    fi
}
# Delete old resource groups created by this script
az group list --query "[?starts_with(name, 'azssh-')].name" -o tsv | while read -r line; do
    az group delete --name $line --yes --no-wait
    if [ $? -eq 0 ]; then
        echo "Successfully deleted resource group $line"
    else
        echo "Failed to delete resource group $line"
    fi
done
# Main function
main() {
    display_message "Starting the deployment process..." "blue"

    check_azure_authentication

    # Get the current public IP of the local machine
    local_ip=$(curl -s https://ipinfo.io/ip)
    echo "your current ip is:" $local_ip

    # Create a resource group
    random_value=$(( $(date +%s%N) + RANDOM ))
    resource_group="azssh-${random_value}"
    az group create --name $resource_group --location southcentralus

    # Generate an SSH key pair
    ssh_key_name="ssh${random_value}_key"
    ssh-keygen -t rsa -b 2048 -f $ssh_key_name -q -N ""

    # Create a Network Security Group with rules
    nsg_name="nsg-${random_value}"
    az network nsg create --resource-group $resource_group --name $nsg_name
    az network nsg rule create --resource-group $resource_group --nsg-name $nsg_name --name DenyAllInbound --priority 1000 --direction Inbound --access Deny --protocol '*' --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges '*'
    az network nsg rule create --resource-group $resource_group --nsg-name $nsg_name --name AllowSSHInbound --priority 200 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes $local_ip/32 --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22

    # Create an Ubuntu VM using the public SSH key
    vm_name="azssh-Ubuntu-${random_value}"
    az vm create --resource-group $resource_group --name $vm_name --image "Canonical:ubuntu-24_04-lts:server:latest" --size Standard_B1s --admin-username sshusername --ssh-key-value "$(cat ${ssh_key_name}.pub)" --nsg $nsg_name

    # Get the public IP of the VM
    public_ip=$(az vm show --name $vm_name --resource-group $resource_group --show-details --query "publicIps" -o tsv)

    # Automatically add the VM's SSH key to known hosts
    ssh-keyscan $public_ip >> ~/.ssh/known_hosts

    # Connect to the VM using the private SSH key
    chmod 600 $ssh_key_name
    ssh -i $ssh_key_name sshusername@$public_ip
}

main

