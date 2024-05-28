# Function to display messages with colors  
function display_message {  
    param(  
        [string]$message,  
        [string]$color  
    )  
  
    switch ($color) {  
        "red"    { Write-Host $message -ForegroundColor Red }  
        "green"  { Write-Host $message -ForegroundColor Green }  
        "yellow" { Write-Host $message -ForegroundColor Yellow }  
        "blue"   { Write-Host $message -ForegroundColor Blue }  
        default  { Write-Host $message }  
    }  
}  
  
# Check Azure authentication  
function check_azure_authentication {  
    try {  
        az account show | Out-Null  
    }  
    catch {  
        display_message "Please authenticate to your Azure account using 'az login --use-device-code'." "red"  
        exit  
    }  
}  
  
# Delete old resource groups created by this script  
function delete_old_resource_groups {  
    $old_groups = az group list --query "[?starts_with(name, 'azssh-')].name" -o tsv  
    if (-not [string]::IsNullOrWhiteSpace($old_groups)) {  
        display_message "Deleting old resource groups created by this script..." "yellow"  
        $old_groups | ForEach-Object { az group delete --name $_ --yes --no-wait }  
    }  
}  
  
# Main function  
function main {  
    display_message "Starting the deployment process..." "blue"  
  
    check_azure_authentication  
  
    # Get the current public IP of the local machine  
    $local_ip = Invoke-RestMethod -Uri https://ipinfo.io/ip  
    Write-Host "your current ip is: $local_ip"  
  
    # Create a resource group  
    $random_value = Get-Random  
    $resource_group = "azssh-$random_value"  
    az group create --name $resource_group --location southcentralus  
  
    # Generate an SSH key pair  
    $ssh_key_name = "ssh${random_value}_key"
    ssh-keygen -t rsa -b 2048 -f $ssh_key_name -q -N ""  
  
    # Create a Network Security Group with rules  
    $nsg_name = "nsg-$random_value"  
    az network nsg create --resource-group $resource_group --name $nsg_name  
    az network nsg rule create --resource-group $resource_group --nsg-name $nsg_name --name DenyAllInbound --priority 1000 --direction Inbound --access Deny --protocol '*' --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges '*'  
    az network nsg rule create --resource-group $resource_group --nsg-name $nsg_name --name AllowSSHInbound --priority 200 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes $local_ip/32 --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22  
  
    # Create an Ubuntu VM using the public SSH key  
    $vm_name = "azssh-Ubuntu-$random_value"  
    az vm create --resource-group $resource_group --name $vm_name --image "Canonical:ubuntu-24_04-lts:server:latest" --size Standard_B1s --admin-username sshusername --ssh-key-value $(Get-Content "${ssh_key_name}.pub") --nsg $nsg_name  
  
    # Get the public IP of the VM  
    $public_ip = az vm show --name $vm_name --resource-group $resource_group --show-details --query "publicIps" -o tsv  
  
    # Automatically add the VM's SSH key to known hosts  
    ssh-keyscan $public_ip >> ~/.ssh/known_hosts  
  
    # Connect to the VM using the private SSH key  
    # Set-Acl -Path $ssh_key_name -AclObject (Get-Acl -Path $ssh_key_name).SetAccessRuleProtection($true, $false)  
    ssh -i $ssh_key_name sshusername@$public_ip  
}  
  
main  
