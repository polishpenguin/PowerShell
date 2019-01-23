#NOTE: WMI Get Commands for retrieving system info

# Get BIOS
Get-WmiObject -Class Win32_BIOS -ComputerName .

# Get Processor 
Get-WmiObject -Class Win32_Processor -ComputerName . | Select-Object -Property [a-z]*

# Get System Type
Get-WmiObject -Class Win32_ComputerSystem -ComputerName . | Select-Object -Property SystemType

# Get Computer Model 
Get-WmiObject -Class Win32_ComputerSystem

# Get Installed Hotfixes
Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName .

# Get OS Version 
Get-WmiObject -Class Win32_OperatingSystem -ComputerName . | Select-Object -Property BuildNumber,BuildType,OSType,ServicePackMajorVersion,ServicePackMinorVersion

# Get Local User and Owner
Get-WmiObject -Class Win32_OperatingSystem -ComputerName . | Select-Object -Property *user*

# Get Available Disk Space
Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ComputerName .

# Get Status of Services
Get-WmiObject -Class Win32_Service -ComputerName . | Format-Table -Property Status,Name,DisplayName -AutoSize -Wrap

# Get IP Address
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Format-Table -Property IPAddress

# Get NIC Info (DHCP, IP, Default Gateway, DNS)
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName .

# Get Detailed NIC Info
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*

