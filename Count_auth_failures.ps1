
# --------------------------------------------------
# Script will request path of CSV of logon status failures, then will the total failures and failures per user.
# This will be output to the console windows and saved in a file in the location the script has been run from.
# --------------------------------------------------


$csv = Read-Host -Prompt 'Enter Authentication Failures CSV File Path'

$failures = import-csv $csv
$total = $failures.count
$users = $failures.user | sort-object
$uniques = ($users | Get-Unique)
$date = Get-Date
echo "Failed Logon Attempts" > Auth_Failures.csv
Write-Host '-------------------------------------------'
Write-Host 'Total Logon Failures:' $total
Start-Sleep -s 1
Write-Host '-------------------------------------------'
Write-Host 'Gathering Individual User Logon Failures...'
Start-Sleep -s 2
Write-Host '-------------------------------------------'
 
foreach ($u in $uniques) {
    
    $user_num = $users | where {$_ -eq $u}
    $user_count = $user_num.count
    write-host $u $user_count
    Add-Content -path Auth_Failures.csv -value "$u - $user_count"
    }

    $dir = get-location
Write-Host '-------------------------------------------'
Write-Host 'Output Saved in' $dir 'as Auth_Failures.csv'
Write-Host '-------------------------------------------'
