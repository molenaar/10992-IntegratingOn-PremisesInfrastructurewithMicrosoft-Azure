<# 
Set-Location 'D:\Mod03\Labfiles'
.\makecert.exe -sky exchange -r -n "CN=AdatumRootCertificate" -pe -a sha1 -len 2048 -ss My "AdatumRootCertificate.cer"
.\makecert.exe -n "CN=AdatumClientCertificate" -pe -sky exchange -m 96 -ss My -in "AdatumRootCertificate" -is my -a sha1
$rootCerText = Get-ChildItem -Path 'Cert:\CurrentUser\My' | Where-Object {$_.Subject -eq 'CN=AdatumRootCertificate'}
$rootCertText = [System.Convert]::ToBase64String($rootCerText.RawData)
$rootCert = New-AzureRmVpnClientRootCertificate -Name AdatumRootCert -PublicCertData $rootCertText
#>

$resourceGroupName        = 'AdatumVNetRG'
$vnetName                 = 'AdatumVNet'
$gwPIPName                = 'AdatumVPNgwPIP'
$gwIPConfigName           = 'AdatumVPNgwConfig'
$gwSubnetName             = 'GatewaySubnet'

$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName
$gwSubnetConfig = Get-AzureRMVirtualNetworkSubnetConfig –Name $gwSubnetName –virtualnetwork $vnet
$gwPIP = Get-AzureRMPublicIPAddress –Name $gwPIPName –ResourceGroupName $resourceGroupName
$gwIPConfig = New-AzureRmVirtualNetworkGatewayIPConfig –Name $gwIPConfigName –Subnet $gwSubnetConfig –PublicIPAddress $gwPIP

New-AzureRmVirtualNetworkGateway -Name AdatumVGateway -ResourceGroupName $resourceGroupName -Location $location -IpConfigurations $gwIPConfig -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard -VpnClientAddressPool '172.16.0.0/24' -VpnClientRootCertificates $rootCert