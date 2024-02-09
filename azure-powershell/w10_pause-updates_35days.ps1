#One liner to set Windows 10 updates to pause (suspend) for +35 days from now:
$pause = (Get-Date).AddDays(35); $pause = $pause.ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ssZ" ); Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseUpdatesExpiryTime' -Value $pause
#one liner to check status (expiry date) of the same:
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'| Select-Object PauseUpdatesExpiryTime
#
#
#
#other ways (classic):
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Force
New-ItemProperty -Path  'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'NoAutoUpdate' -PropertyType DWORD -Value 1 
#
#
#legacy: 
>cmd
sc.exe config wuauserv start=disabled
sc.exe query wuauserv
sc.exe stop wuauserv
#
