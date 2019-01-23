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
$script:app_list = Get-Application_List -Property Publisher,InstallDate,DisplayVersion,InstallSource,IsMinorUpgrade,ReleaseType,ParentDisplayName,SystemComponent | Where-Object {[string]$_.SystemComponent -ne 1 -and ![string]$_.IsMinorUpgrade -and ![string]$_.ReleaseType -and ![string]$_.ParentDisplayName} | Sort-Object ProgramName | Select-Object ProgramName, DisplayVersion | Format-Table -AutoSize


# displays QA info
$QA_Report = @"

###########################################################
###################### FULL QA LIST: ######################
###########################################################
-----------------------------------------------------------
###################### SYSTEM INFO: #######################
-----------------------------------------------------------
INFO: HIT QA PROCESS FOR WINDOWS: https://confluence.savvis.net/display/GlobalSD/QA+Process+Windows

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
            "INFO: This is a VM since VMWare Tools are installed, continuing QA..."
     }
     else {
            "INFO: VMWare Tools are not installed, must be standalone server... "
          }
)
$(If (Test-Path 'C:\Chef'){
            "INFO: Chef is not fully uninstalled, please investigate and remove"
     }
     else {
            "INFO: Chef is not installed, continuing QA..."
          }
)
INFO: ALL APPLICATIONS INSTALLED AND VERSIONS, MATCH WITH HTOF AND NOTES BELOW:
NOTE: SIA latest version = 3.17
NOTE: McAfee latest version = 8.8
NOTE: NBU latest version = 7.7.2
$($script:app_list | Out-String)

-----------------------------------------------------------
#################### MANUAL QA CHECKS: ####################
-----------------------------------------------------------

"INFO: IF Standalone server(s), manually verify iLO login and standard settings" 
"INFO: IF Standalone server(s), verify RAID level and disk sizes" 
"INFO: IF Standalone server(s), manually verify HTOF, iLO, and Vantive match on CPU type, MEM, Disk, OS, Server model, Server name(s)" 
"INFO: IF Standalone server(s), check if Vantive DAS port relationships exist" 
"INFO: IF Standalone server(s), verify that MPIO, Emulex Drivers, Emulex Firmware, System Firmware is updated, and HBAnywhere software is installed"
"INFO: IF HTOF/Tech Docs list any managed app(s), check Vantive for AIPs" 

"INFO: IF VM, manually check if virtual hardware is latest version in vCenter: https://confluence.savvis.net/display/~Steven.Kondracki/VMware+-+Virtual+hardware+versions" 
"INFO: IF VM, manually check if VM has floppy drive removed in vCenter"
"INFO: IF VM, manually check if isolation parameters are set using .\checkem.ps1 in PowerCLI"

"INFO: Manually check admin account in password repo (https://password.savvis.net/)" 
"INFO: Manually check DNS PTR and A records in opstats (https://opstats.savvis.net/)" 
"INFO: Manually check SIA traps in opstats and copy/paste into QA email (https://opstats.savvis.net/)" 
"INFO: Manually check if windows udpates are installed" 
"INFO: Manually check if NBU 2.0 is configured: https://confluence.savvis.net/display/HBU/DPBU+Settings+by+Data+Center" 

"INFO: IF HTOF/Tech Docs list managed Active Directory, verify all checks" 
"INFO: IF HTOF/Tech Docs list managed MSSQL standalone, clustered, or always on, verify all checks" 
"INFO: IF HTOF/Tech Docs list managed RDS, verify all checks" 
"INFO: IF HTOF/Tech Docs list managed IIS, verify all checks" 
"INFO: IF Lasso is installed, check telnet over 514 to Lasso device IP in tech docs"








"@

clear
Write-Output $QA_Report
$QA_Report | Out-File "C:\XFER\QA_REPORT_ $(get-date -f MM-dd-yyyy).txt"
$QA_Report | Out-File "C:\XFER\QA_REPORT_ $(get-date -f MM-dd-yyyy).doc"
$QA_Report | Out-File "C:\XFER\QA_REPORT_ $(get-date -f MM-dd-yyyy).rtf"


Write-Host "INFO: Report sent to 'C:\XFER\QA_REPORT_<DATE>.txt', please clear (shift+del) once reviewed" -foreground "magenta" -background "black" `n

#Exit-PSSession





