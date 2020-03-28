param (
    [Parameter(Mandatory=$true)][string]$appname,
    [Parameter(Mandatory=$true)][string]$apppassword
)

$identifieruri = 'http://' + $appname + '/'
$dsazadapplication = New-AzADApplication -DisplayName $appname -IdentifierUris $identifieruri
$dsaztenant = Get-AzTenant
$today = get-date
$twoyears = $today.AddYears(2)
$azadcreds = ConvertTo-SecureString -String $apppassword -asplaintext -force
$azadcredentials = New-AzADAppCredential -ApplicationObject $dsazadapplication -Password $azadcreds -EndDate $twoyears -StartDate $today
$azadsubs = get-azsubscription
#for multiple subscriptions, will need to do a for-each loop
$azsubsscope = "/subscriptions/" + $azadsubs
$azadserviceprincipal = New-AzADServicePrincipal -ApplicationID $dsazadapplication.ApplicationId
Write-host "waiting 30 seconds for Azure replication" -ForegroundColor Cyan
start-sleep 30
$azroleassignment = New-AzRoleAssignment -ApplicationId $dsazadapplication.ApplicationId -RoleDefinitionName Reader -Scope $azsubsscope
write-host "You will need the below" -ForegroundColor Yellow
write-host "--------------------------------------------"
write-host "Active Directory ID     :" $azadsubs.TenantId -ForegroundColor Green
write-host "Subscription ID         :" $azadsubs.Id -ForegroundColor Green
write-host "Application ID          :" $dsazadapplication.ApplicationId -ForegroundColor Green
write-host "Password                : I'm not telling you" -ForegroundColor Green




<#
Get-AzRoleAssignment -ObjectId $dsazadapplication.ObjectId -Scope $azsubsscope

Remove-AzADAppCredential -ApplicationObject $dsazadapplication -force
Remove-AzADApplication -InputObject $dsazadapplication -Force
Remove-AzRoleAssignment -InputObject $azroleassignment
#>
