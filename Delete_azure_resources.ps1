#Install Azure powershell first:
#Install-Module -Name Az -AllowClobber -Scope CurrentUser
#set-executionpolicy -scope process -executionpolicy remotesigned
#Import-Module Az.Accounts
#connect-azaccount
param (
    [Parameter(Mandatory=$true)][string]$azusername,
    [Parameter(Mandatory=$true)][string]$azpassword
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

#Get-AzVM -resourcegroupname $mtresourcegroupname | Stop-AzVM -force
$demovm = Get-AzVM -resourcegroupname $mtresourcegroupname
$demovm | Stop-AzVM -SkipShutdown -force
$demovm | Remove-AzVM -Force

Get-AzNetworkInterface -ResourceGroupName $mtresourcegroupname | Remove-AzNetworkInterface -Force
Get-AzPublicIpAddress -ResourceGroupName $mtresourcegroupname | Remove-AzPublicIpAddress -Force
Get-AzDisk -ResourceGroupName $mtresourcegroupname | Remove-AzDisk -Force
Get-AzStorageAccount -resourcegroupname $mtresourcegroupname | Remove-AzStorageAccount
Get-AzNetworkSecurityGroup -ResourceGroupName $mtresourcegroupname | Remove-AzNetworkSecurityGroup -Force
Get-AzVirtualNetwork -ResourceGroupName $mtresourcegroupname | Remove-AzVirtualNetwork -Force
Get-AzResourceGroup -Name $mtresourcegroupname | Remove-AzResourceGroup -Force
