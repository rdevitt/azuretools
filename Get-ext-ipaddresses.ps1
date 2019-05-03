<#

Script will parse through all subs and extract all external IPs currently assigned
within the tenant. It will then output as a txt file.

Note that script does not list sub names for each in output txt file, just a list
which can be sent to another script/app. This could be easily amended to include
subscription info as well if required.

#>


#login to AzureCLI. Use: "az login"


###############  Sub Processing: ###############

"Extracting subscriptions:"
$var1 = az account list -o tsv --query [[].name]
$var2 = $var1 -replace "`t","`n"
$subs = $var2.split("`n")
"---------------------"
"Number of Subscriptions found in Azure Tenant:"
$subs.count
$si = $subs.count
"---------------------"
"Looping through subscriptions:"

foreach ($sub in $subs)
{
    Write-host "Setting subscription to:" $sub
    az account set -s $sub

###############  IP Processing: ###############

    $t = az network public-ip list
    $n = $t.count
    Write-host "Total IP Addresses =" $n
    $i = 0

    while ($i -lt $n)
    {
    $p = $i + 1
    Write-Host "IP #" $p
    $ip = az network public-ip list --query [[$i].ipAddress] -o tsv
    Write-Host $ip
    $i++
    Add-Content ip_addresses_output.txt $ip
    }
}
