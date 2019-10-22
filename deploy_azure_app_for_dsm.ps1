param (
    [Parameter(Mandatory=$true)][string]$appname,
    [Parameter(Mandatory=$true)][string]$apppassword
)

$dsazadapplication = New-AzADApplication -DisplayName $appname -IdentifierUris http://localhost/
$dsaztenant = Get-AzTenant
$today = get-date
$twoyears = $today.AddYears(2)
$azadcreds = ConvertTo-SecureString -String $apppassword -asplaintext -force
$azadcredentials = New-AzADAppCredential -ApplicationObject $dsazadapplication -Password $azadcreds -EndDate $twoyears -StartDate $today
$azadsubs = get-azsubscription
#for multiple subscriptions, will need to do a for-each loop
$azsubsscope = "/subscriptions/" + $azadsubs
$azadserviceprincipal = New-AzADServicePrincipal -ApplicationID $dsazadapplication.ApplicationId
$azroleassignment = New-AzRoleAssignment -ApplicationId $dsazadapplication.ApplicationId -RoleDefinitionName Reader -Scope $azsubsscope





<#
Get-AzRoleAssignment -ObjectId $dsazadapplication.ObjectId -Scope $azsubsscope

Remove-AzADAppCredential -ApplicationObject $dsazadapplication -force
Remove-AzADApplication -InputObject $dsazadapplication -Force
Remove-AzRoleAssignment -InputObject $azroleassignment
#>
