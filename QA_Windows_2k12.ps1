# HIT_QA_Windows_2k12.ps1
# This script provides a detailed explanation of HIT's Windows QA process and manual checks for standalone and virtual servers.
# This script DOES NOT make any changes on the server, all the QA checks are read only and can be re-ran many times.
# This script DOES NOT yet provide QA checks for managed applications such as AD, RDS, MSSQL, and IIS.
# This script can be ran on any Windows 2012 server and most checks will work on 2008 as well.
# This script can be ran on multiple servers using HPSA ad-hoc PowerShell method, or copy/paste into PowerShell window using admin rights.
# This script will output all results and manual check info into "C:\XFER\QA_WIN_SERVER_REPORT_<CURRENT_DATE>.rtf" (assumes C:\xfer exists)
# This script will auto check and return the following:
# 1. current date
# 2. server short name
# 3. server fqdn
# 4. os version 
# 5. cpu type and amount
# 6. memory modules and amount
# 7. chassis serial
# 8. bios version and date
# 9. local admin list
# 10. xfer info
# 11. timezone
# 12. nic adapter type and duplex speed
# 13. default gateway
# 14. ipv4 info
# 15. static routes
# 16. disk info
# 17. applications installed and versions
# 18. sia out of bounds alerts
# 19. list of manual checks required to pass qa

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
    $script:bios = Get-WmiObject -class "Win32_BIOS" -namespace "root\CIMV2" | Select Manufacturer, SMBIOSBIOSVersion
    $script:bios_date = gwmi Win32_BIOS;($bios_date.ConvertToDateTime($bios_date.releasedate).ToShortDateString())
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
    #$script:nic = Get-WmiObject  -Class Win32_NetworkAdapter | `
                  #Where-Object { $_.Speed -ne $null -and $_.MACAddress -ne $null } | `
                  #Format-Table -Property Name, NetConnectionID,@{Label='Speed(Mbps)'; Expression = {[Int](($_.Speed/1MB))}} 
    $script:nic2 = Get-NetAdapter | SELECT InterFaceDescription, Status, LinkSpeed, FullDuplex | where Status -eq 'up'
}

Function Get-DefaultGateway{
    $script:gateway = (Get-wmiObject Win32_networkAdapterConfiguration | ?{$_.IPEnabled}).DefaultIPGateway
    
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

Function Get-Application_List {

    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(ValueFromPipeline              =$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0
        )]
        [string[]]
            $ComputerName = $env:COMPUTERNAME,
        [Parameter(Position=0)]
        [string[]]
            $Property,
        [switch]
            $ExcludeSimilar,
        [int]
            $SimilarWord
    )

    begin {
        $RegistryLocation = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\',
                            'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
        $HashProperty = @{}
        $SelectProperty = @('ProgramName','ComputerName')
        if ($Property) {
            $SelectProperty += $Property
        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
            $RegistryLocation | ForEach-Object {
                $CurrentReg = $_
                if ($RegBase) {
                    $CurrentRegKey = $RegBase.OpenSubKey($CurrentReg)
                    if ($CurrentRegKey) {
                        $CurrentRegKey.GetSubKeyNames() | ForEach-Object {
                            if ($Property) {
                                foreach ($CurrentProperty in $Property) {
                                    $HashProperty.$CurrentProperty = ($RegBase.OpenSubKey("$CurrentReg$_")).GetValue($CurrentProperty)
                                }
                            }
                            $HashProperty.ComputerName = $Computer
                            $HashProperty.ProgramName = ($DisplayName = ($RegBase.OpenSubKey("$CurrentReg$_")).GetValue('DisplayName'))
                            if ($DisplayName) {
                                New-Object -TypeName PSCustomObject -Property $HashProperty |
                                Select-Object -Property $SelectProperty
                            } 
                        }
                    }
                }
            } | ForEach-Object -Begin {
                if ($SimilarWord) {
                    $Regex = [regex]"(^(.+?\s){$SimilarWord}).*$|(.*)"
                } else {
                    $Regex = [regex]"(^(.+?\s){3}).*$|(.*)"
                }
                [System.Collections.ArrayList]$Array = @()
            } -Process {
                if ($ExcludeSimilar) {
                    $null = $Array.Add($_)
                } else {
                    $_
                }
            } -End {
                if ($ExcludeSimilar) {
                    $Array | Select-Object -Property *,@{
                        name       = 'GroupedName'
                        expression = {
                            ($_.ProgramName -split $Regex)[1]
                        }
                    } |
                    Group-Object -Property 'GroupedName' | ForEach-Object {
                        $_.Group[0] | Select-Object -Property * -ExcludeProperty GroupedName
                    }
                }
            }
        }
   }
}

function Get-SIA {
    $script:sia = c:\usr\local\monitor\monitor status | findstr /c:Inv /c:Bound
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
Get-DefaultGateway
Get-IP_Info
Get-Routes
Get-Disk_Info
Get-SIA
$script:app_list = Get-Application_List -Property Publisher,InstallDate,DisplayVersion,InstallSource,IsMinorUpgrade,ReleaseType,ParentDisplayName,SystemComponent | Where-Object {[string]$_.SystemComponent -ne 1 -and ![string]$_.IsMinorUpgrade -and ![string]$_.ReleaseType -and ![string]$_.ParentDisplayName} | Sort-Object ProgramName | Select-Object ProgramName, DisplayVersion | Format-Table -AutoSize


# displays QA info
$QA_Report = @"
-----------------------------------------------------------
##################### MANUAL QA CHECKS: ###################
-----------------------------------------------------------
###########################################################
############## Standalone (Physical) Servers: #############
###########################################################
############## 1ST SET OF MANUAL QA CHECKS: ###############
INFO: HIT QA PROCESS FOR WINDOWS: https://confluence.savvis.net/display/GlobalSD/QA+Process+Windows
1. Verify iLO login
2. Verify RAID level and disk sizes (standard win 2012 = 100 GB C: and D: remaining, RAID 1 (mirror) config)
3. Verify HTOF, iLO, and Vantive match on CPU type, MEM, Disk Type, OS, Server model, Server name
4. Check if Vantive DAS port relationships exist
5. Verify that MPIO, Emulex Drivers, Emulex Firmware, System Firmware is updated, and HBAnywhere software is installed
6. If HTOF/Tech Docs list any managed app(s), check Vantive for AIPs
############## 2ND SET OF MANUAL QA CHECKS: ###############
7. If server has been joined to the NA domain verify that the OU has been created for the SiteID in NA AD
8. Verify that the NA-Server-Admins group is in the local Administrators Group and Remote Desktop Users group. (Dedicated domains will only have us in local Admin Group)
9. If the server is in a dedicated domain, verify the NA trust works by logging in with your NA creds 
10. Check if adminh0st1ng account is in password repo (https://password.savvis.net/)
11. Check DNS PTR and A records in opstats (https://opstats.savvis.net/)
12. Check SIA traps in opstats and copy/paste into QA email (https://opstats.savvis.net/)
13. Check if windows udpates are installed
14. Check if NBU 2.0 is configured: https://confluence.savvis.net/display/HBU/DPBU+Settings+by+Data+Center
15. Verify McAfee Virus Scan Console lists task "(managed) Savvis_Managed_Update"
########## MANAGED APPLICATIONS (AFTER OS QA): ############
16. If HTOF/Tech Docs list managed Active Directory, verify all checks 
17. If HTOF/Tech Docs list managed MSSQL standalone, clustered, or always on, verify all checks
18. If HTOF/Tech Docs list managed RDS, verify all checks
19. If HTOF/Tech Docs list managed IIS, verify all checks
20. If HTOF/Tech Docs list managed Tripwire, verify security team has verified console communication
21. If HTOF/Tech Docs list managed Lasso, check telnet over 514 to Lasso device IP in tech docs

###########################################################
################# Virtual Machines (VMs): #################
###########################################################
############## 1ST SET OF MANUAL QA CHECKS: ###############
1. Check if virtual hardware is latest version in vCenter: https://confluence.savvis.net/display/~Steven.Kondracki/VMware+-+Virtual+hardware+versions
2. Check if VM has floppy drive removed in vCenter
3. Check if isolation parameters are set using .\checkem.ps1 in PowerCLI
4. Check if VMWare Tools are up to date in vCenter 
############## 2ND SET OF MANUAL QA CHECKS: ###############
5. If server has been joined to the NA domain verify that the OU has been created for the SiteID in NA AD
6. Verify that the NA-Server-Admins group is in the local Administrators Group and Remote Desktop Users group. (Dedicated domains will only have us in local Admin Group)
7. If the server is in a dedicated domain, verify the NA trust works by logging in with your NA creds 
8. Check if adminh0st1ng account is in password repo (https://password.savvis.net/)
9. Check DNS PTR and A records in opstats (https://opstats.savvis.net/)
10. Check SIA traps in opstats and copy/paste into QA email (https://opstats.savvis.net/)
11. Check if windows udpates are installed
12. Check if NBU 2.0 is configured: https://confluence.savvis.net/display/HBU/DPBU+Settings+by+Data+Center
13. Verify McAfee Virus Scan Console lists task "(managed) Savvis_Managed_Update"
######### MANAGED APPLICATIONS (AFTER OS QA): #############
14. If HTOF/Tech Docs list managed Active Directory, verify all checks 
15. If HTOF/Tech Docs list managed MSSQL standalone, clustered, or always on, verify all checks
16. If HTOF/Tech Docs list managed RDS, verify all checks
17. If HTOF/Tech Docs list managed IIS, verify all checks
18. If HTOF/Tech Docs list managed Tripwire, verify security team has verified console communication
19. If HTOF/Tech Docs list managed Lasso, check telnet over 514 to Lasso device IP in tech docs
###########################################################
-----------------------------------------------------------
################## AUTOMATED QA CHECKS: ###################
-----------------------------------------------------------
-----------------------------------------------------------
###################### SYSTEM INFO: #######################
-----------------------------------------------------------
$(If (Test-Path 'C:\Program Files\VMware\VMware Tools'){
        cd 'C:\Program Files\VMware\VMware Tools'
        $script:vmware_version = .\VMwareToolboxCmd.exe -v
            "INFO: This is a VM since VMWare Tools are installed, continuing QA..."
     }
     else {
            "INFO: VMWare Tools are not installed, must be standalone server... "
          }
)
INFO: QA Date: $($date)
INFO: Server Short Name: $($hostname) 
INFO: Server FQDN: $($fqdn)
INFO: Operating System Version: $($os_version) 
INFO: CPU Type: 
$($cpu.Name | Out-String)
INFO: CPU Cores: $($cpu.NumberOfCores)
INFO: CPU Logical Processors: $($cpu.NumberOfLogicalProcessors)
INFO: Total Memory (GB): $($totalmemory)
INFO: Memory Modules (MB): $($memory)
INFO: Chassis Serial: $($chassis_serial.SerialNumber)
INFO: BIOS Manufacturer: $($script:bios.Manufacturer)
INFO: BIOS Version: $($script:bios.SMBIOSBIOSVersion)
INFO: BIOS Date: $($bios_date.ConvertToDateTime($bios_date.releasedate).ToShortDateString())
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
INFO: NIC(s) type, status, and duplex speed:
$($script:nic2 | Out-String)
INFO: Default Gateway is: $($script:gateway)
INFO: IP Info per Interface: 
$($script:ip_info | Out-String)
INFO: Persistent (Static) Routes: 
$($script:get_routes.Description | Out-String)
-----------------------------------------------------------
###################### STORAGE INFO: ######################
-----------------------------------------------------------
INFO: Disk Info: 
$($script:get_disk | Out-String)
-----------------------------------------------------------
#################### APPLICATION INFO: ####################
-----------------------------------------------------------
$(If (Test-Path 'C:\Chef'){
            "INFO: Chef is not fully uninstalled, please investigate and remove"
     }
     else {
            "INFO: Chef is not installed, continuing QA..."
          }
)
INFO: ALL APPLICATIONS INSTALLED AND VERSIONS ARE LISTED BELOW, PLEASE MANUALLY MATCH WITH HTOF AND THE FOLLOWING:
NOTE: SIA latest version = 3.17
NOTE: McAfee latest version = 8.8
NOTE: NBU latest version = 7.7.2
INFO: List of apps installed on system:
$($script:app_list | Out-String)
INFO: SIA Out of Bounds alerts if any are listed below, please clear: $($script:sia | Out-String)
-----------------------------------------------------------
###################### QA COMPLETE: #######################
-----------------------------------------------------------


"@
cd -Path C:\Users\$env:UserName
#clear
Write-Output $QA_Report
$QA_Report | Out-File "C:\XFER\QA_WIN_SERVER_REPORT_$(get-date -f MM-dd-yyyy).rtf"

Write-Host "INFO: Report sent to 'C:\XFER\QA_WIN_SERVER_REPORT_$(get-date -f MM-dd-yyyy).rtf', please clear (shift+del) once reviewed" -foreground "cyan" -background "black" 
Write-Host "INFO: Report can be best displayed by opening it in WordPad and selecting view tab, word wrap, no wrap" -foreground "cyan" -background "black" 






