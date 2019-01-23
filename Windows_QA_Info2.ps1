Function System_Info {
    
#Get-Hostname
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    "Now running System/OS QA tests... " >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    $hostname = hostname
    "1. Hostname is: $hostname " >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-OS
    "2. Operating System and Version is: " >> c:\xfer\Windows_QA_Info.txt
	systeminfo | findstr /B /C:"OS Name" /C:"OS Version" | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    # Get-WmiObject -Class Win32_OperatingSystem | Format-Table Caption, ServicePackMajorVersion -AutoSize
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-CPU
    "3. CPU, Core, and Logical Processor is: " >> c:\xfer\Windows_QA_Info.txt
    Get-WmiObject –class Win32_processor | ft Name,NumberOfCores,NumberOfLogicalProcessors -AutoSize | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-Memory
    "4. Memory modules installed in MB are: " >> c:\xfer\Windows_QA_Info.txt
    get-ciminstance -class "cim_physicalmemory" | % {$_.Capacity / 1MB} | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    #$Memory = systeminfo | findstr /C:"Total Physical Memory"
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    
#Get-Chassis_Serial
    "5. Chassis Serial is:"  >> c:\xfer\Windows_QA_Info.txt
    gwmi win32_bios | fl SerialNumber | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-BIOS_Version
    $Bios = systeminfo | findstr /I /c:bios
    "6. BIOS Version and Date is: $Bios " >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-Disk
    "7. Disk Info:"  >> c:\xfer\Windows_QA_Info.txt
    Get-WmiObject -Class Win32_LogicalDisk |
    Where-Object {$_.DriveType -ne 5} |
    Sort-Object -Property Name | 
    Select-Object Name, VolumeName, FileSystem, Description, VolumeDirty, `
        @{"Label"="DiskSize(GB)";"Expression"={"{0:N}" -f ($_.Size/1GB) -as [float]}}, `
        @{"Label"="FreeSpace(GB)";"Expression"={"{0:N}" -f ($_.FreeSpace/1GB) -as [float]}}, `
        @{"Label"="%Free";"Expression"={"{0:N}" -f ($_.FreeSpace/$_.Size*100) -as [float]}} |
    Format-Table -AutoSize | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-Local_Admin_List
    "8. Local Admin List is: " >> c:\xfer\Windows_QA_Info.txt
    net localgroup administrators | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt


}


Function Network_Info {
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    "Now running Network QA tests... " >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-TimeZone
    $TimeZone = tzutil /g
    "9. TimeZone is set to $TimeZone " >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-DuplexSpeed
    "10. Network Adapter(s) info and Duplex speed: " >> c:\xfer\Windows_QA_Info.txt
    Get-WmiObject  -Class Win32_NetworkAdapter | `
    Where-Object { $_.Speed -ne $null -and $_.MACAddress -ne $null } | `
    Format-Table -Property Name, NetConnectionID,@{Label='Speed(MB)'; Expression = {[Int](($_.Speed/1MB)*1.05)}} -AutoSize | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-Routes
    "11. Network active and persistent routes are: " >> c:\xfer\Windows_QA_Info.txt
	Netstat -rn | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-IP_Info
    "12. IP and Gateway info for each interface is: " >> c:\xfer\Windows_QA_Info.txt
	netsh interface ip show addresses | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt



#Get-VM-NICDriverType (use PowerCLI for this)
#Get-Cluster "cluster_name" | Get-VM -Name "vm_name" |  Get-NetworkAdapter

}

Function Application_Info {

    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    "Now running Managed Application QA tests... " >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-SQL-Info
    "13. Application - SQL Info is: " >> c:\xfer\Windows_QA_Info.txt
    If (test-path "C:\Program Files\Microsoft SQL Server"){
    Invoke-Sqlcmd -Query "SELECT @@VERSION;" -QueryTimeout 3
	$inst = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
	foreach ($i in $inst)
	    {
	       $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$i
	       (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Edition
	       (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Version
	    }
    }
    else {
	"INFO: SQL is NOT installed, continuing managed app tests..." >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
#Get-IIS-Info
    "14. Application - IIS Info is: " >> c:\xfer\Windows_QA_Info.txt
	$IIS = get-wmiobject -query "select * from Win32_Service where name='W3svc'" 
    if ($IIS -eq $null){
    "INFO: IIS is NOT installed, continuing managed app tests..." >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
    else {
    "INFO: IIS IS installed, continuing managed app tests..." >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
#Get-AD-Info
    "15. Application - Active Directory Info is: " >> c:\xfer\Windows_QA_Info.txt
	If (!(Test-Path D:\SYSVOL))
        {
        write-output "INFO: 'D:\SYSVOL' doesn't exist, Active Directory is NOT installed, continuing managed app tests..." >> c:\xfer\Windows_QA_Info.txt
        "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
        }
        else {
        write-output "INFO: 'D:\SYSVOL' exists, Active Directory IS installed, continuing managed app tests..." >> c:\xfer\Windows_QA_Info.txt
        "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
#Get-RDS-Info
    $check = Get-WindowsFeature "RDS-RD-Server"
    If ($check.Installed -eq $True) {
    "INFO: Remote Desktop Services (RDS) role IS installed, continuing managed app tests..." >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
    else {
    "INFO: Remote Desktop Services (RDS) role is NOT installed, continuing managed app tests..." >> c:\xfer\Windows_QA_Info.txt
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
#Get-McAfee-Info
    "17. Application - McAfee Info is: " >> c:\xfer\Windows_QA_Info.txt
	
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-NBU-Info
    "18. Application - Symantec Net Backup Utility (NBU) Info is: " >> c:\xfer\Windows_QA_Info.txt
	
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-SIA-Info
    "19. Application - SIA Info is: " >> c:\xfer\Windows_QA_Info.txt
	
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt



}
cls
#Get-XFER-Info
    if( (Get-ChildItem C:\xfer | Measure-Object).Count -eq 0)
    {
        "C:\XFER is Empty, continue...Shift+Delete this file 'Windows_QA_Info.txt' once reviewed to pass QA"  >> c:\xfer\Windows_QA_Info.txt
        "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
    else {
        "C:\XFER is NOT empty, please investigate if data is needed or clear it after this QA report is run:"  >> c:\xfer\Windows_QA_Info.txt
        "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    }
    


#Test-Path_XFER
If (!(Test-Path c:\xfer))
        {write-output "ERROR: C:\XFER doesn't exist and is required, please create it or run on system with C:\XFER to view QA Results"}
    else
        {write-output "INFO: C:\XFER exists, writing QA Results to filename 'Windows_QA_Info.txt', please wait..."}


#Function Calls
System_Info
Network_Info
Application_Info

#Final Info printed to screen and file
write-output "INFO: Check directory C:\XFER and filename 'Windows_QA_Info.txt' to view QA Results"
write-output "INFO: Shift+Delete this file 'Windows_QA_Info.txt' once reviewed to pass QA"
             "INFO: Shift+Delete this file 'Windows_QA_Info.txt' once reviewed to pass QA" >>  c:\xfer\Windows_QA_Info.txt





#Get-CPU
    "3. CPU, Core, and Logical Processor is: " >> c:\xfer\Windows_QA_Info.txt
    Get-WmiObject –class Win32_processor | ft Name,NumberOfCores,NumberOfLogicalProcessors -AutoSize | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt

#Get-Memory
    "4. Memory modules installed in MB are: " >> c:\xfer\Windows_QA_Info.txt
    get-ciminstance -class "cim_physicalmemory" | % {$_.Capacity / 1MB} | out-file -FilePath c:\xfer\Windows_QA_Info.txt -Append
    #$Memory = systeminfo | findstr /C:"Total Physical Memory"
    "############################################################################################" >>  c:\xfer\Windows_QA_Info.txt
    



###############################################



Function Get-CurrentDate {

    $date = (Get-Date).ToString()

}

Function Get-ServerName {
   
    [string]$hostname = hostname 
}

Function Get-OSVersion {

    [string]$os_version = gwmi win32_operatingsystem | % caption

}

Function Get-CPU {

    $cpu = Get-WmiObject –class Win32_processor | Select Name,NumberOfCores,NumberOfLogicalProcessors 
    
}

Function Get-Memory {


} 

# calls functions
Get-CurrentDate
Get-ServerName
Get-OSVersion
Get-CPU



# displays QA info
$QA_Report = @"

###########################################################
###################### FULL QA LIST: ######################
###########################################################

###################### SYSTEM INFO: #######################
QA Date: $($date)
Server Name: $($hostname) 
Operating System Version: $($os_version) 
CPU Type: $($cpu.Name)
CPU Cores: $($cpu.NumberOfCores)
CPU Logical Processors: $($cpu.NumberOfLogicalProcessors)
4.  Server - RAM
5.  Server - Serial
6.  Server - BIOS
7.  Server - Disk
8.  Server - Local Admin Accounts

###################### NETWORK INFO: ######################
9.  Network - Time Zone
10. Network - NIC Speed
11. Network - Routes
12. Network - IP and Default Gateway 

###################### STORAGE INFO: ######################

########## APPLICATION INFO: ##########
13. Application - SQL Info
14. Application - IIS Info
15. Application - AD Info
16. Application - RDS Info
17. Application - McAfee Info
18. Application - NBU Info
19. Application - SIA Info



"@

clear
Write-Output $QA_Report








