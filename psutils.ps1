#test
$cred = Get-Credential -Credential administrateur
$path = Read-Host -Prompt 'Type the path for IPs.txt'
$content = Get-Content -Path $path
$computernames = @()
foreach ($line in $content)
{
    $computernames += $line
}
Write-Host "Select the operation you would like to perform" -foregroundcolor "Green"
Write-Host "1. Check current time in remote system" -foregroundcolor "Green"
Write-Host "2. Check service status in a remote system" -foregroundcolor "Green"
Write-Host "3. Disable windows update service in remote pc" -foregroundcolor "Green"
$options =  Read-Host -Prompt 'Select option :'

switch ($options)

{

1 {

        for ($a=0; $a -lt $computernames.Length; $a++) {
          $total = $computernames.Length
          Write-Progress -Activity "Working..." `
           -PercentComplete ($a/$computernames.Length *100) -CurrentOperation "$a of $total complete"  `
           -Status "Please wait."
           if(Test-Connection -BufferSize 32 -Count 1 -ComputerName $computernames[$a] -Quiet)
           {
           $time = gwmi win32_localtime -computer $computernames[$a] -credential $cred
           Write-Host "$($time.PSComputerName) Current local time is $($time.Hour):$($time.Minute):$($time.Second)" 
           }
           else { write-host $computernames[$a] "is offline" -foregroundcolor "Red"}
        }
    }
2 {
        $service = Read-Host -Prompt 'Type the Service Name:'
        $colitems = @()
        for ($a=0; $a -lt $computernames.Length; $a++) {
          $total = $computernames.Length
          Write-Progress -Activity "Working..." `
           -PercentComplete ($a/$computernames.Length *100) -CurrentOperation "$a of $total complete"  `
           -Status "Please wait."
           if(Test-Connection -BufferSize 32 -Count 1 -ComputerName $computernames[$a] -Quiet)
           {$colitems += Get-WMIObject Win32_Service -ComputerName $computernames[$a] -credential $cred | Where { $_.Name -eq $service }}
           else { write-host $computernames[$a] "is offline" -foregroundcolor "Red"}
        }
        $colitems |Format-Table Name,startmode,state,PSComputerName -AutoSize

  }

3 {
 
        for ($a=0; $a -lt $computernames.Length; $a++) 
        {
          $total = $computernames.Length
          Write-Progress -Activity "Working..." `
           -PercentComplete ($a/$computernames.Length *100) -CurrentOperation "$a of $total complete"  `
           -Status "Please wait."
           if(Test-Connection -BufferSize 32 -Count 1 -ComputerName $computernames[$a] -Quiet)
               {
                $service = Get-WmiObject Win32_Service -Filter 'Name="wuauserv"' -ComputerName $computernames[$a] -credential $cred 
                    if($service.state -ne "Stopped")
                       { $service.StopService()
                         $Service.PSComputerName + " Service stoppped"
                       } else{ $Service.PSComputerName + " Service is already stopped"}
                    if($service.StartMode -ne "Disabled")
                        {
                        $service.ChangeStartMode("Disabled")
                        $Service.PSComputerName +  "Service startmode is set to disabled"                     
                        }else{ $Service.PSComputerName + " Service startmode is already disabled"}
               }
           else { write-host $computernames[$a] "is offline" -foregroundcolor "Red"}
        }
   }
}