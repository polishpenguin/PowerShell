#Enter-PSSession -computername $env:COMPUTERNAME -ConfigurationName Microsoft.PowerShell32

Function Get-CurrentDate { 
    [string]$script:date = (Get-Date).ToString()
}

Function Get-ServerName { 
    [string]$script:hostname = hostname 
    [string]$script:fqdn = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName   
}

Function Get-OSVersion {
    [string]$script:os_version = Get-WmiObject win32_operatingsystem | % caption  
}

Function Get-CPU {
    $script:cpu = Get-WmiObject –class Win32_processor | Select Name,NumberOfCores,NumberOfLogicalProcessors       
}

Function Get-Memory {
    [int]$script:totalmemory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))}
    $script:memory = Get-CimInstance -class "cim_physicalmemory" | % {$_.Capacity / 1MB} 
} 

Function Get-Chassis_Serial {
    $script:chassis_serial = Get-WmiObject win32_bios | Select SerialNumber
}

Function Get-BIOS_Version {
    $script:bios = Get-WmiObject -class "Win32_BIOS" -namespace "root\CIMV2" | Select Manufacturer, Version, Caption
}

Function Get-Local_Admin_List {
    $script:admin = invoke-command {
                        net localgroup administrators | 
                        where {$_ -AND $_ -notmatch "command completed successfully"} | 
                        select -skip 4
                        }                        
}

Function Get-XFER-Info {
    $script:xfer = (Get-ChildItem C:\xfer | Measure-Object).Count   
}  

Function Get-TimeZone {
    $script:timezone = tzutil /g  
}

Function Get-DuplexSpeed {
    $script:nic = Get-WmiObject  -Class Win32_NetworkAdapter | `
                  Where-Object { $_.Speed -ne $null -and $_.MACAddress -ne $null } | `
                  Format-Table -Property Name, NetConnectionID,@{Label='Speed(Mbps)'; Expression = {[Int](($_.Speed/1MB)*1.05)}} 
}


Function Get-IP_Info {  
	$script:ip_info = netsh interface ip show addresses
}

Function Get-Routes {     
    $script:get_routes = get-wmiobject -class "Win32_IP4PersistedRouteTable" -namespace "root\CIMV2" 
        foreach ($object in $get_routes) { 
        write-host "Persistent Route: " $object.Description 
        } 
  
}

Function Get-Disk_Info {
    $script:get_disk = Get-WmiObject -Class Win32_LogicalDisk |
    Where-Object {$_.DriveType -ne 5} |
    Sort-Object -Property Name | 
    Select-Object Name, VolumeName, FileSystem, Description, `
        @{"Label"="DiskSize(GB)";"Expression"={"{0:N}" -f ($_.Size/1GB) -as [float]}}, `
        @{"Label"="FreeSpace(GB)";"Expression"={"{0:N}" -f ($_.FreeSpace/1GB) -as [float]}}, `
        @{"Label"="%Free";"Expression"={"{0:N}" -f ($_.FreeSpace/$_.Size*100) -as [float]}} |
    Format-Table -AutoSize 
}

Function Get-McAfee_Info {

$script:mcafee = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Where-Object {$_.DisplayName -like "McAfee*"}

}


# calls functions
Get-CurrentDate
Get-ServerName
Get-OSVersion
Get-CPU
Get-Memory
Get-Chassis_Serial
Get-BIOS_Version
Get-Local_Admin_List
Get-XFER-Info
Get-TimeZone
Get-DuplexSpeed
Get-IP_Info
Get-Routes
Get-Disk_Info
Get-McAfee_Info

# displays QA info
$QA_Report = @"

###########################################################
###################### FULL QA LIST: ######################
###########################################################
-----------------------------------------------------------
###################### SYSTEM INFO: #######################
-----------------------------------------------------------
INFO: QA Date: $($date)
INFO: Server Short Name: $($hostname) 
INFO: Server FQDN: $($fqdn)
INFO: Operating System Version: $($os_version) 
INFO: CPU Type: $($cpu.Name | Out-String)
INFO: CPU Cores: $($cpu.NumberOfCores | Out-String)
INFO: CPU Logical Processors: $($cpu.NumberOfLogicalProcessors | Out-String)
INFO: Total Memory (GB): $($totalmemory  | Out-String)
INFO: Memory Modules (MB): $($memory | Out-String)
INFO: Chassis Serial: $($chassis_serial.SerialNumber)
INFO: BIOS Version: $($script:bios | Out-String)
INFO: Local Admin List: 
$($script:admin | Out-String)
INFO: $(if ($script:xfer -eq 0)
    {
        "C:\XFER is empty, continuing QA..."   
    }
    else {
        "C:\XFER is NOT empty, please investigate or clear it..." 
    })   
-----------------------------------------------------------
###################### NETWORK INFO: ######################
-----------------------------------------------------------
INFO: Time Zone: $($script:timezone)
INFO: Network Adapter(s) Name, Type, Speed: 
$($script:nic | Out-String)
INFO: IP Info per Interface: 
$($script:ip_info | Out-String)
INFO: Persistent (Static) Routes: 
$($script:get_routes.Description)
-----------------------------------------------------------
###################### STORAGE INFO: ######################
-----------------------------------------------------------
INFO: Disk Info: 
$($script:get_disk | Out-String)
-----------------------------------------------------------
#################### APPLICATION INFO: ####################
-----------------------------------------------------------
$(If (Test-Path 'C:\Program Files\VMware\VMware Tools'){
        cd 'C:\Program Files\VMware\VMware Tools'
        $script:vmware_version = .\VMwareToolboxCmd.exe -v
            "INFO: VMWare Tools are installed, version: $script:vmware_version"
     }
     else {
            "INFO: VMWare Tools are not installed, must be standalone server... "
          }
)
INFO: McAfee Version:
$($script:mcafee)

MSSQL Installed y/n?
If installed, instance name, version, 
IIS Installed y/n?
AD Installed y/n?
RDS Installed y/n?
McAfee Version:
NBU Version:
SIA Version:
Chef installed y/n?
LogLogic Installed?
Tripwire Installed?

INFO: check admin account in repo
INFO: check DNS PTR and A records in opstats
INFO: check SIA traps
INFO: If standalone, Check ILO
INFO: If standalone, Check RAID level
INFO: If standalone, Check Vantive DAS Port Relationships
INFO: If managed apps, Check Vantive AIPs
INFO: if lasso check telnet over 514
INFO: check if windows udpates are installed



"@

clear
Write-Output $QA_Report
$QA_Report | Out-File "C:\XFER\QA_REPORT_ $(get-date -f MM-dd-yyyy).txt"
Write-Host "INFO: Report sent to 'C:\XFER\QA_REPORT_<DATE>.txt', please clear (shift+del) once reviewed" -foreground "magenta" -background "black" 
#Exit-PSSession





