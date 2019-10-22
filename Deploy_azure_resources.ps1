#Install Azure powershell first:
#Install-Module -Name Az -AllowClobber -Scope CurrentUser
#set-executionpolicy -scope process -executionpolicy remotesigned -force
#Import-Module Az.Accounts
param (
    [Parameter(Mandatory=$true)][string]$azusername,
    [Parameter(Mandatory=$true)][string]$azpassword,
    [Parameter(Mandatory=$true)][string]$loginusername,
    [Parameter(Mandatory=$true)][string]$loginpassword
)
$mtlocation = "westus2"
$mtresourcegroupname = "Demo"
$mtstorageaccountname = "523bbcf97f0d"
$mtvirtualnetworkname = "Demovirtualnetwork"
$mtpubipaddressname = "Demo-pubip2"
$mtnetworksecuritygroupname = "Internetfacing-westus2"
$mtavailabilityset1 = "Demo-as1"
#VM settings
$mtvmname = "az-dmo2"
$mtvmnicname = "az-dmo2-NIC"
$mtvmsize = "Standard_B1ms"
$mtvmpublisher = "MicrosoftWindowsServer"
$mtvmoffer = "WindowsServer"
$mtvmsku = "2019-Datacenter-smalldisk"
$mtvmversion = "2019.0.20190603"
$mtdemousername = $azusername
$mtdemopassword = $azpassword
$mtdemosecurepassword = Convertto-SecureString -String $mtdemopassword -AsPlainText -force
$mtdemocredentials = New-object System.Management.Automation.PSCredential $mtdemousername,$mtdemosecurepassword
$mtusername = $loginusername
$mtclearpassword = $loginpassword
$mteecurePassword = Convertto-SecureString -String $mtclearpassword -AsPlainText -force
$mtcredentials=New-object System.Management.Automation.PSCredential $mtusername,$mteecurePassword


Connect-AzAccount -credential $mtdemocredentials -ErrorAction Stop

$mtresourcegroup = New-AzResourceGroup -Location $mtlocation -Name $mtresourcegroupname
$frontendSubnet = New-AzVirtualNetworkSubnetConfig -Name frontendSubnet -AddressPrefix "10.10.1.0/24"
$backendSubnet = New-AzVirtualNetworkSubnetConfig -Name backendSubnet -AddressPrefix "10.10.2.0/24"
$mtvirtualnetwork = New-AzVirtualNetwork -Name $mtvirtualnetworkname -ResourceGroupName $mtresourcegroupname -Location $mtlocation -AddressPrefix "10.10.0.0/16" -Subnet $frontendSubnet,$backendSubnet
$mtpubipaddress = New-AzPublicIpAddress -AllocationMethod Dynamic -ResourceGroupName $mtresourcegroupname -IpAddressVersion IPv4 -Location $mtlocation -Name $mtpubipaddressname
$rule1 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$rule2 = New-AzNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22
$mtnetworksecuritygroup = New-AzNetworkSecurityGroup -ResourceGroupName $mtresourcegroupname -Location $mtlocation -Name $mtnetworksecuritygroupname -SecurityRules $rule1,$rule2
$mtvmnic = New-AzNetworkInterface -Name $mtvmnicname -ResourceGroupName $mtresourcegroupname -Location $mtlocation -SubnetId $mtvirtualnetwork.Subnets[0].Id -PublicIpAddressId $mtpubipaddress.Id -NetworkSecurityGroupId $mtnetworksecuritygroup.Id
$mtvmconfig = New-AzVMConfig -VMName $mtvmname -VMSize $mtvmsize | `
Set-AzVMOperatingSystem -Windows -ComputerName $mtvmname -Credential $mtcredentials | `
Set-AzVMSourceImage -PublisherName $mtvmpublisher -Offer $mtvmoffer -Skus $mtvmsku -Version $mtvmversion | `
Add-AzVMNetworkInterface -Id $mtvmnic.Id
New-AzVM -ResourceGroupName $mtresourcegroupname -Location $mtlocation -VM $mtvmconfig
