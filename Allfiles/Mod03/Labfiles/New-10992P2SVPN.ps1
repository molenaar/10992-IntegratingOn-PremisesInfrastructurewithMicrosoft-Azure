Add-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $subscriptionName

$resourceGroupName        = 'AdatumVNetRG'
$vnetName                 = 'AdatumVNet'
$addressPrefix            = '192.168.0.0/16'
$frontendSubnetName       = 'FrontEndSubnet'
$addressPrefixfeSubnet    = '192.168.0.0/24'
$gwSubnetName             = 'GatewaySubnet'
$addressPrefixgwSubnet    = '192.168.255.224/27'
$gwPIPName                = 'AdatumVPNgwPIP'
$gwIPConfigName           = 'AdatumVPNgwConfig'

New-AzureRMResourceGroup –Name $resourceGroupName –Location $location
$vnet = New-AzureRMVirtualNetwork –ResourceGroupName $resourceGroupName –Name $vnetName –AddressPrefix $addressPrefix –Location $location
Add-AzureRmVirtualNetworkSubnetConfig -Name $frontEndSubnetName -VirtualNetwork $vnet -AddressPrefix $addressPrefixFESubnet
Add-AzureRmVirtualNetworkSubnetConfig -Name $gwSubnetName -VirtualNetwork $vnet -AddressPrefix $addressPrefixGWSubnet

$gwSubnetConfig = Get-AzureRMVirtualNetworkSubnetConfig –Name $gwSubnetName –virtualnetwork $vnet
$gwPIP = New-AzureRMPublicIPAddress –Name $gwPIPName –ResourceGroupName $resourceGroupName -AllocationMethod Dynamic -Location $location
$gwIPConfig = New-AzureRmVirtualNetworkGatewayIPConfig –Name $gwIPConfigName –Subnet $gwSubnetConfig –PublicIPAddress $gwPIP
Set-AzureRMVirtualNetwork –VirtualNetwork $vnet
