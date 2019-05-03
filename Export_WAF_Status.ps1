<#

Script will grab all the subs and resource groups in a tenant and parse through them to check all the WAFs and grab status info.
It will then output this to a CSV file

NOTE: Output can be bit noisey with errors when it doesn't find any WAFs in a group, however these can be ignored.


#>


#$subs = get-content subs_static.txt

"-------------------------------------------------------------------------"
"Running script to extract WAF Status from attached Azure Tenant......."
"-------------------------------------------------------------------------"

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

$main = foreach ($sub in $subs) 
{
    az account set -s $sub
    Write-host "Processing" $sub
    $var1 = az resource list --resource-type Microsoft.Network/applicationGateways -o tsv --query [[].name]
    $var1 -replace "`t","`n" | Out-File var1.txt
    $gws = gc var1.txt
    
    foreach ($gw in $gws) 
    {
        $rg = az resource list --resource-type Microsoft.Network/applicationGateways -n $gw -o tsv --query [[].resourceGroup]
        #$rg  = $var2 -replace "`t","`n"
        $set = az network 'application-gateway' waf-config show --resource-group $rg --gateway-name $gw -o tsv --query [firewallMode]
         
        new-object psobject -Property @{
            Subscription = $sub
            ResourceGroup = $rg
            ApplicationGateway = $gw
            FirewallMode = $set
             }
    }
}
"Exported to waf-settings.csv"

$main | export-csv waf-settings.csv