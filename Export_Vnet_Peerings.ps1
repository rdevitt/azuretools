
### README Below: ###
<#

    This script will grab all subs in a tenant and parse through them to pull out all vnet peerings in all resource groups,
    save to a table, and output as a CSV file.

    You will need to log into a Azure CLI Tenant in powershell first to run this 
    script against it.

    Output is quite verbose, so will keep you informed what's happening.

    Script takes a while to run, I suggest you go get a coffee or something.

#>

"-----------------------------------------------------------------------"
"Running script to extra Vnet Peerings from attached Azure Tenant......."
"-----------------------------------------------------------------------"
###### Define the Array ######

$AllObjects = @()

############### Subscription Processing: ###############

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

###############################


#$table =

foreach ($sub in $subs)
{
    Write-host "###########################################"
    Write-host "Number of subscriptions still to process:" $si
    Write-host "###########################################"
    Write-host "Setting subscription to:" $sub
    Write-host "###########################################"
    az account set -s $sub

###############  Resource Group Processing: ###############

    Write-host "---------------------"
    Write-host "Extracting Resource Groups:"
    Write-host "---------------------"
    $var1 = az network vnet list -o tsv --query [[].resourceGroup]
    $var2 = $var1 -replace "`t","`n"
    $rgs = $var2.split("`n")

    Write-Host "---------------------"
    Write-Host "Number of Resource Groups found in Subscription" $sub ":"
    $rgs.count
    $ri = $rgs.count
    Write-Host "---------------------"

############### Get Resource Groups: ###############

foreach ($rg in $rgs)

    {
        Write-host "*****************************************************"
        Write-host "Number of Resource Groups still to process in" $sub ":" $ri
        Write-host "*****************************************************"
        Write-host "Processing Resource Group:" $rg
        Write-host "*****************************************************"
        
###############  Vnet Processing: ###############

        Write-host "Extracting Virtual Networks:"
        $var1 = az network vnet list --resource-group $rg -o tsv --query [[].name]
        $var2 = $var1 -replace "`t","`n"
        $vnts = $var2.split("`n")
        
        Write-Host "---------------------"
        Write-Host "Number of VNets found in Resource Group" $rg ":"
        Write-Host $vnts.count
        $vi = $vnts.count
        $vi2 = 0

        
        foreach ($vnt in $vnts)
        {
            Write-host "----------------------------------------------------- "
            Write-host "Number of subscriptions still to process:" $si
            Write-host "Number of Resource Groups still to process in:" $sub ":" $ri
            Write-host "Number of Vnets still to process in" $rg ":" $vi
            Write-host "----------------------------------------------------- "
            Write-host "Processing VNet:" $vnt
            Write-host "--------------- "
        $vni = $vnt

        $sn = az network vnet list --resource-group $rg -o tsv --query [[$vi2].addressSpace.addressPrefixes]
        Write-Host "Vnet Range:" $sn

        $vi2++

############### Peering Processing: ###############

            $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[].name]
            $var2 = $var1 -replace "`t","`n" 
            $prs = $var2.split("`n")
            $pri = $prs.count
            Write-Host "----------------------------------------------------- "
            Write-host "Number of Peerings found in" $vnt ":" $pri
            Write-host "----------------------------------------------------- "
            
            $pi = 0

            Write-host "Looping through Peerings:"
            Write-host "--------------- "
            Write-host "Extracting Peering Info:"

            foreach ($pr in $prs)
            {
                Write-host "--------------- "
                Write-host "Processing Peering: "
                Write-host "Number of Peerings found in" $vnt ":" $pri
                Write-Host $vnt "Peering: #" ($pi +1) $pr
                Write-host "--------------- "
                Write-host "Exporting Peering State..."

                ### Pull out attributes from peerings:
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].peeringState]
                $var2 = $var1 -replace "`t","`n"
                $state =  $var2.split("`n")

                Write-host "Exporting Provisioning State..."
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].provisioningState]
                $var2 = $var1 -replace "`t","`n"
                $prov =  $var2.split("`n")

                Write-host "Exporting Traffic Forwarding Settings..."
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].allowForwardedTraffic]
                $var2 = $var1 -replace "`t","`n"
                $fwdt =  $var2.split("`n")

                Write-host "Exporting VPN Access Settings..."
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].allowGatewayTransit]
                $var2 = $var1 -replace "`t","`n"
                $gwt =  $var2.split("`n")

                Write-host "Exporting VNet Access Settings..."
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].allowVirtualNetworkAccess]
                $var2 = $var1 -replace "`t","`n"
                $vna =  $var2.split("`n")

                Write-host "Exporting Remote Gateway Settings..."
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].useRemoteGateway]
                $var2 = $var1 -replace "`t","`n"
                $urg =  $var2.split("`n")

                Write-host "Exporting Peered Subnet Details..."
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].remoteAddressSpace.addressPrefixes]
                $var2 = $var1 -replace "`t","`n"
                $psn =  $var2.split("`n")

                Write-host "Exporting Peering ID & Remote Resource Name..."
                $var1 = az network vnet peering list --resource-group $rg --vnet-name $vnt -o tsv --query [[$pi].remoteVirtualNetwork.id]
                $var2 = $var1 -replace "`t","`n"
                $var3 =  $var2.split("`n")
                $rrn = $var3.split("/")[8]

                Write-host "--------------- "


############### True table: ###############
                #New-Object -TypeName psobject -Property @{
                $AllObjects += [pscustomobject]@{
                    "Subscription" = $sub
                    "ResourceGroup" = $rg
                    "VirtualNetwork" = $vni
                    "LocalVnetAddressSpace" = (@($sn) -join '')
                    "PeeringName" = $pr
                    "PeeringState" = (@($state) -join '')
                    "ProvisioningState" = (@($prov) -join '')
                    "AllowForwardedTraffic" = (@($fwdt) -join '')
                    "AllowGatewayTransit" = (@($gwt) -join '')
                    "AllowVirtualNetworkAccess" = (@($vna) -join '')
                    "UseRemoteGateway" = (@($urg) -join '')
                    "RemotePeerAddressSpace" = (@($psn) -join '')
                    "RemoteResourceName" = (@($rrn) -join '')        
                    } 
                $pi++  
                }
            
            $vi--
            }
        $ri--
        }
$si-- 
 }




############### Outputting Results: ###############

$AllObjects | ft
$AllObjects | Select-Object | export-csv -NoTypeInformation peering-settings.csv

"##########################################################################"
"Output into current directory as peering-settings.csv"
"##########################################################################"
" "
" "


