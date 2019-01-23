#requires -module EnhancedHTML2
<#
.SYNOPSIS
Generates an HTML-based system report for one or more computers.
Each computer specified will result in a separate HTML file;
specify the -Path as a folder where you want the files written.
Note that existing files will be overwritten.
.PARAMETER ComputerName
One or more computer names or IP addresses to query.
.PARAMETER Path
The path of the folder where the files should be written.
.PARAMETER CssPath
The path and filename of the CSS template to use.
.EXAMPLE
.\New-HTMLSystemReport -ComputerName ONE,TWO `
-Path C:\Reports\
#>
[CmdletBinding()]
param(
[Parameter(Mandatory=$True,
ValueFromPipeline=$True,
ValueFromPipelineByPropertyName=$True)]
[string[]]$ComputerName,
[Parameter(Mandatory=$True)]
[string]$Path
)

BEGIN {
Remove-Module EnhancedHTML2
Import-Module EnhancedHTML2
}


PROCESS {
$style = @"
<style>
body {
color:#333333;
font-family:Calibri,Tahoma;
font-size: 10pt;
}
h1 {
text-align:center;
}
h2 {
border-top:1px solid #666666;
}
th {
font-weight:bold;
color:#eeeeee;
background-color:#333333;
cursor:pointer;
}
.odd { background-color:#ffffff; }
.even { background-color:#dddddd; }
.paginate_enabled_next, .paginate_enabled_previous {
cursor:pointer;
border:1px solid #222222;
background-color:#dddddd;
padding:2px;
margin:4px;
border-radius:2px;
}
.paginate_disabled_previous, .paginate_disabled_next {
color:#666666;
cursor:pointer;
background-color:#dddddd;
padding:2px;
margin:4px;
border-radius:2px;
}
.dataTables_info { margin-bottom:4px; }
.sectionheader { cursor:pointer; }
.sectionheader:hover { color:red; }
.grid { width:100% }
.red {
color:red;
font-weight:bold;
}
</style>
"@


function Get-InfoOS {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)][string]$ComputerName
)
$os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $ComputerName
$props = @{'OSVersion'=$os.version
'SPVersion'=$os.servicepackmajorversion;
'OSBuild'=$os.buildnumber}
New-Object -TypeName PSObject -Property $props
}
function Get-InfoCompSystem {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)][string]$ComputerName
)
$cs = Get-WmiObject -class Win32_ComputerSystem -ComputerName $ComputerName
$props = @{'Model'=$cs.model;
'Manufacturer'=$cs.manufacturer;
'RAM (GB)'="{0:N2}" -f ($cs.totalphysicalmemory / 1GB);
'Sockets'=$cs.numberofprocessors;
'Cores'=$cs.numberoflogicalprocessors}
New-Object -TypeName PSObject -Property $props
}
function Get-InfoBadService {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)][string]$ComputerName
)
$svcs = Get-WmiObject -class Win32_Service -ComputerName $ComputerName `
-Filter "StartMode='Auto' AND State<>'Running'"
foreach ($svc in $svcs) {
$props = @{'ServiceName'=$svc.name;
'LogonAccount'=$svc.startname;
'DisplayName'=$svc.displayname}
New-Object -TypeName PSObject -Property $props
}
}
function Get-InfoProc {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)][string]$ComputerName
)

$procs = Get-WmiObject -class Win32_Process -ComputerName $ComputerName
foreach ($proc in $procs) {
$props = @{'ProcName'=$proc.name;
'Executable'=$proc.ExecutablePath}
New-Object -TypeName PSObject -Property $props
}
}
function Get-InfoNIC {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)][string]$ComputerName
)
$nics = Get-WmiObject -class Win32_NetworkAdapter -ComputerName $ComputerName `
-Filter "PhysicalAdapter=True"
foreach ($nic in $nics) {
$props = @{'NICName'=$nic.servicename;
'Speed'=$nic.speed / 1MB -as [int];
'Manufacturer'=$nic.manufacturer;
'MACAddress'=$nic.macaddress}
New-Object -TypeName PSObject -Property $props
}
}
function Get-InfoDisk {
[CmdletBinding()]
param(
[Parameter(Mandatory=$True)][string]$ComputerName
)
$drives = Get-WmiObject -class Win32_LogicalDisk -ComputerName $ComputerName `
-Filter "DriveType=3"
foreach ($drive in $drives) {
$props = @{'Drive'=$drive.DeviceID;
'Size'=$drive.size / 1GB -as [int];
'Free'="{0:N2}" -f ($drive.freespace / 1GB);
'FreePct'=$drive.freespace / $drive.size * 100 -as [int]}
New-Object -TypeName PSObject -Property $props
}
}