# Sign in to Azure
Login-AzureRmAccount

# Select the target subscription
$subscriptionName = '<subscription_name>'
$subscription = Select-AzureRmSubscription -SubscriptionName $subscriptionName

# use the same Azure region and the VM size of the Azure VM deployed in the previous exercise
$subscriptionId = $subscription.Subscription.SubscriptionId
$vm0 = Get-AzureRmResource -ResourceId "/subscriptions/$subscriptionId/providers/Microsoft.Compute/virtualMachines" -ApiVersion 2017-12-01 | 
       Where-Object {$_.Name -like '10992B*'}
$location = $vm0[0].Location
$vmSize = $vm0[0].Properties.hardwareProfile.vmSize

$rgName	= '10992B0102-LabRG'
$vmName = '10992B0101-vm2'
$pubName = 'MicrosoftWindowsServer'
$offerName = 'WindowsServer'
$skuName = '2016-Datacenter'
$vnetName = '10992B0102-LabRG-vnet'
$vnetPrefix = '10.1.0.0/20'
$subnetName = 'default'
$subnetPrefix = '10.1.0.0/24'
$nsgName = "$vmName-nsg"
$pipName = "$vmName-ip" 
$nicName = "$vmName-nic"
$osDiskName = "$vmName-OsDisk"
$osDiskSize = 128
$osDiskType = 'StandardLRS'

# create a resource group
New-AzureRmResourceGroup -Name $rgName -Location $location

# create a virtual network and a subnet
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
      -Name $subnetName `
      -AddressPrefix $subnetPrefix

$vnet = New-AzureRmVirtualNetwork `
      -ResourceGroupName $rgName `
      -Location $location `
      -Name $vnetName `
      -AddressPrefix $vnetPrefix `
      -Subnet $subnetConfig

$subnetId = (Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet).Id

# Create admin credentials
$adminUsername = 'Student'
$adminPassword = 'Pa55w.rd1234'
$adminCreds = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force) 

# Create an network security group (NSG)
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name 'default-allow-rdp' -Protocol Tcp -Direction Inbound -Priority 1000 `
                    -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Location $location -Name $nsgName -SecurityRules $nsgRuleRDP

# Create a public IP and NIC
$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic 
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location `
      -SubnetId $subnetid -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Set VM Configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $adminCreds 
Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $pubName -Offer $offerName -Skus $skuName -Version 'latest'
Set-AzureRmVMOSDisk -VM $vmConfig -Name $osDiskName -DiskSizeInGB $osDiskSize -StorageAccountType $osDiskType -CreateOption fromImage

#Create the VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vmConfig