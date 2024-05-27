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
  
# Find an available port  
find_available_port() {  
    while true; do  
        port=$(( 10000 + RANDOM % 20000 ))  
        (echo >/dev/tcp/127.0.0.1/$port) &>/dev/null || break  
    done  
    echo $port  
}  
  
# Main function  
main() {  
    display_message "Starting the deployment process..." "blue"  
  
    check_azure_authentication  
  
    # Create a resource group  
    random_value=$(( $(date +%s%N) + RANDOM ))  
    az group create --name $random_value --location southcentralus  
  
    # Generate an SSH key pair  
    ssh_key_name="ssh${random_value}_key"  
    ssh-keygen -t rsa -b 2048 -f $ssh_key_name -q -N ""  
  
    # Create an Ubuntu VM using the public SSH key  
    az vm create --resource-group $random_value --name UbuntuVM --image "Canonical:ubuntu-24_04-lts:server:latest" --size Standard_B1s  --admin-username sshusername --ssh-key-value "$(cat ${ssh_key_name}.pub)"  
  
    # Get the public IP of the VM  
    public_ip=$(az vm show --name UbuntuVM --resource-group $random_value --show-details --query "publicIps" -o tsv)  
  
    # Automatically say yes to SSH key warning  
    ssh-keyscan $public_ip >> ~/.ssh/known_hosts  
  
    # Connect to the VM using the private SSH key  
    chmod 600 $ssh_key_name  
    ssh -i $ssh_key_name sshusername@$public_ip

}  
main  
