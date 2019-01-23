# Gets server uptime
function Get-ComputerUptime {
	$pc = Get-WmiObject -Class Win32_OperatingSystem
	$booted = $pc.ConvertToDateTime($pc.LastBootUpTime)
	$uptime = (Get-Date) - $booted

	write-host "INFO: Computer Uptime is: " #[String]::Format('{0:00} Days, {1:00} Hours, {2:00} Minutes, {3:00} Seconds', $uptime.Days, $uptime.Hours, $uptime.Minutes, $uptime.Seconds)
    [String]::Format('{0:00} Days, {1:00} Hours, {2:00} Minutes, {3:00} Seconds', $uptime.Days, $uptime.Hours, $uptime.Minutes, $uptime.Seconds)
}



# Gets default gateway and tests ping 
function Ping-Gateway {
    
    $script:gateway = (Get-wmiObject Win32_networkAdapterConfiguration | ?{$_.IPEnabled}).DefaultIPGateway
    $script:gateway = 2# ping doesn't return true/false
    $response = ping $script:gateway

       if (!$response)
           {write-host "INFO: Pinging default gateway $script:gateway failed";}
       else
           {write-host "INFO: Pinging default gateway $script:gateway succeeded!";}
}


# Function Calls
Get-ComputerUptime
Ping-Gateway