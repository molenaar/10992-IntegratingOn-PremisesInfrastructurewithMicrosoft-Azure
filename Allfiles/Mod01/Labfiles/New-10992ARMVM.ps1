Add-AzureRmAccount
$subscriptionName 	= '<subscription_name>'
$location		= '<Azure_region_name>'
Select-AzureRmSubscription -SubscriptionName $subscriptionName

$armvm2RGName		= 'armvm2RG'
New-AzureRmResourceGroup -Name $armvm2RGName -Location $location

$randomString		= (Get-Date).Ticks.ToString().Substring(8)
$armvm2saName		= $armvm2RGName.ToLower() + 'sa' + $randomString
$armvm2saType		= 'Standard_LRS'
$vm2RGstorageAcct 	= New-AzureRmStorageAccount -Name $armvm2saName -ResourceGroupName $armvm2RGName -Kind Storage -SkuName $armvm2saType -Location $location

$armvm2Name		= 'armvm2'
$armvm2Size		= 'Basic_A1'
$publisherName		= 'MicrosoftWindowsServer'
$offerName		= 'WindowsServer'
$skuName		= '2012-R2-Datacenter'
$version		= 'latest'

$armvm2VNetName		= 'armvm2VNet'
$armvm2VNetPrefix	= '10.0.0.0/16'
$armvm2SubnetName	= 'default'
$armvm2SubnetPrefix	= '10.0.0.0/24'

$armvm2Subnet		= New-AzureRmVirtualNetworkSubnetConfig -Name $armvm2SubnetName -AddressPrefix $armvm2SubnetPrefix
$armvm2Vnet			= New-AzureRmVirtualNetwork -Name $armvm2VNetName -ResourceGroupName $armvm2RGName -Location $location -AddressPrefix $armvm2VNetPrefix -Subnet $armvm2Subnet
$armvm2SubnetConfig 	= Get-AzureRmVirtualNetworkSubnetConfig -Name $armvm2SubnetName -VirtualNetwork $armvm2VNet

$armvm2nicName		= $armvm2Name + 'nic0001'
$iparmvm2		= New-AzureRmPublicIpAddress -Name $armvm2nicName -ResourceGroupName $armvm2RGName -Location $location -AllocationMethod Dynamic
$nicarmvm2 		= New-AzureRmNetworkInterface -Name $armvm2nicName -ResourceGroupName $armvm2RGName `
        				-Location $location -SubnetId $armvm2SubnetConfig.Id -PublicIpAddressId $iparmvm2.Id

$adminUserName		= 'Student'
$adminPass		= 'Pa$$w0rd1234'
$adminPassSecure	= ConvertTo-SecureString -String $adminPass -AsPlainText -Force
$credentials		= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUserName, $adminPassSecure

$armvm2Config 		= New-AzureRmVMConfig -VMName $armvm2Name -VMSize $armvm2Size
$armvm2Config 		= Set-AzureRmVMOperatingSystem -VM $armvm2Config -Windows -ComputerName $armvm2Name -Credential $credentials -ProvisionVMAgent
$armvm2Config 		= Set-AzureRmVMSourceImage -VM $armvm2Config -PublisherName $publisherName -Offer $offerName -Skus $skuName -Version $version
$armvm2Config 		= Add-AzureRmVMNetworkInterface -VM $armvm2Config -Id $nicarmvm2.Id
$osDiskName 		= $armvm2Name.ToLower() + $randomString
$osVhdUri 		= $vm2RGstorageAcct.PrimaryEndpoints.Blob.ToString() + 'vhds/' + $osDiskName + '.vhd'
$armvm2Config 		= Set-AzureRmVMOSDisk -VM $armvm2Config -Name $osDiskName -VhdUri $osVhdUri -CreateOption fromImage

New-AzureRmVM -VM $armvm2Config -ResourceGroupName $armvm2RGName -Location $location
