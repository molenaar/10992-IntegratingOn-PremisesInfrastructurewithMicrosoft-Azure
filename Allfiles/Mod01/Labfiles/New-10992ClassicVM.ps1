Add-AzureAccount

$subscriptionName 	= '<subscription_name>'
$location		= '<Azure_region_name>'
Select-AzureSubscription -SubscriptionName $subscriptionName –Current

$classicvm2Name		= 'classicvm2'
$classicvm2Size		= 'Basic_A0'

$randomString		= (Get-Date).Ticks.ToString().Substring(8)
$classicvm2saName	= $classicvm2Name.ToLower() + 'sa' + $randomString
$classicvm2saType	= 'Standard_LRS'
New-AzureStorageAccount -StorageAccountName $classicvm2saName -location $location -Type $classicvm2saType
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccountName $classicvm2saName

$classicvm2svcName	= $classicvm2Name.ToLower() + 'svc' + $randomString

$imageFamily		= 'Windows Server 2012 R2 Datacenter*'
$image  		= (Get-AzureVMImage | Where-Object {$_.Label –like $imageFamily} | Sort-Object PublishedDate)[-1]
$classicvm2		= New-AzureVMConfig -Name $classicvm2Name -InstanceSize $classicvm2Size -ImageName $image.imageName

$adminUserName		= 'Student'
$adminPassword		= 'Pa$$w0rd1234'
$classicvm2 | Add-AzureProvisioningConfig -Windows -AdminUsername $adminUserName -Password $adminPassword

New-AzureVM –ServiceName $classicvm2svcName -VMs $classicvm2 -Location $location