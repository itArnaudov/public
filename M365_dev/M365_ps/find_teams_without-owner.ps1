Get-Team | Where-Object {$_.Owners -eq $null}
# or
$teams = Get-Team -Filter "Visibility eq 'Public'" | Where-Object {$_.Owners -eq $null}

foreach ($team in $teams) {
    Write-Output $team.Name
}
# or
Get-Team -Filter "Visibility eq 'Public'" | Where-Object {$_.Owners -eq $null}
#
