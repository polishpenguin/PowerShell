# Last reboot WMI
Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime'
;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}

# Last reboot CIM
Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime

# importing modules to sessions (implicit remoting)
Import-PSSession -session $session -Module ActiveDirectory -Prefix remote

# implicit remoting locally test
$s = nsn
Import-PSSession $s -CommandName get-process -Prefix Pawel
Get-PawelProcess


[cmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string[]]$ComputerName
)

Get-WmiObject -ComputerName $ComputerName -class win32_logicaldisk -Filter "Device"

# Cntrl + J brings up cmdlet snippets, which you can use as templates
# modlue paths: 
$env:PSModulePath -split ";"
# folder and module name must be same








#region " PowerShell Version Check "

$PSVersionTable.PSVersion

#endregion


#region " OS Version & Service Pack Check "

Get-WmiObject -Class Win32_OperatingSystem | Format-Table Caption, ServicePackMajorVersion -AutoSize

#endregion


#region " .NET 4.5 Check "

(Get-ItemProperty -Path ‘HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full’ -ErrorAction SilentlyContinue).Version -like ‘4.5*’

#endregion

# Get Commands
Get-Service -DisplayName win*

Get-Command -CommandType cmdlet
Get-Command *service* -CommandType cmdlet
Get-Command *service* -CommandType cmdlet -Module ActiveDirectory
Get-Command -verb get -noun service
Get-Command

# updating help from the internet
Get-Help Update-Help -Examples
Update-Help

# saving & updating help locally
Save-Help -DestinationPath \\fsnugget\psv4\help
Update-Help -SourcePath \\fsnugget\psv4\help

# searching help
Get-Help *variable*
Get-Help about_automatic_variables -ShowWindow

# getting help
help Get-Service -Detailed #params & examples
help Get-Service -Examples #examples
help Get-Service -Full #full help: params, examples, notes, input/output types
help Get-Service -Parameter d*

# using help
help Get-Service -ShowWindow
Get-Service bi* -ComputerName DCNUGGET, FSNUGGET | Select-Object MachineName,Status, DisplayName | Format-List

help Start-Service -Online
Get-Service bi* -ComputerName DCNUGGET, FSNUGGET | Start-Service #input object parameter set
Start-Service -DisplayName 'Background Intelligent Transfer Service' -c DCNUGGET, FSNUGGET #displayname parameter set
Start-Service

#--------------------------------------------------
# Challenges for PowerShell 4 Foundations: Commands
#--------------------------------------------------


# I: Display all services running on the localhost that have a displayname beginning with the letter B

#region " Solution for I "

Get-Service -DisplayName b*

#endregion


# II: Display a list of commands that are cmdlets in any module that starts with Microsoft

#region " Solution for II "

Get-Command -CommandType Cmdlet -Module Microsoft*

#endregion


# III: Copy the contents of a directory, including subdirectories from one location to another
# 1. Find all cmdlets that start with the verb 'copy'
# 2. Review the help topic for Copy-Item
# 3. Use Copy-Item with positional parameters
# 4. Switch directories (cd) to the destination directory and list the contents (dir)
# 5. Discover the cmdlets underneath the aliases cd and dir used above

#region " Solution for III "

Get-Command -Verb copy
Get-Help Copy-Item
Copy-Item '\\fsnugget\psv4' 'c:\' -recurse
cd 'c:\psv4'
dir
Get-Alias cd, dir
#endregion

# commands
Get-Help Get-Command -Parameter CommandType

Get-Command *proc* -CommandType Cmdlet
Get-Command p* -CommandType Application
Get-Command cl* -CommandType Function

Get-Verb

Get-Command *service*
Get-Help New-Service -ShowWindow
Show-Command New-Service

New-Service -BinaryPathName c:\system32\notepad.exe `
            -Name np -Description "Notepad as a service for fun" `
            -DisplayName Notepad `
            -StartupType Disabled

(Get-WmiObject -Class Win32_Service -Filter "Name='np'").delete()

# aliases
Get-Command -CommandType alias

Get-Alias dir
Get-Alias ls
Get-Alias -Definition Get-Childitem

Help *alias*
Get-Help New-Alias
New-Alias np c:\system32\notepad.exe #wrong path
Set-Alias -Name np -Value notepad.exe

np

Export-Alias my-aliases.csv
Import-Alias my-aliases.csv

np

#------------------------------------------------------
# Challenges for PowerShell 4 Foundations: The Pipeline
#------------------------------------------------------


# I: Write a pipeline that returns only running services and sort the results in descending order by displayname

#region " Solution for I "

Get-Service | Where-Object Status -eq Running | Sort-Object DisplayName

#endregion


# II: Write a pipeline that retrieves a list of files over 1GB on the system drive and save the results to an html file

#region " Solution for II "

Get-ChildItem $env:SystemDrive | Where-Object Length -gt 1GB | ConvertTo-HTML | Out-File \\fsnugget\psv4\files\bigones.html

#endregion


# III: Write a pipeline that retrieves the name, synopsis, and modulename properties from get-help for all "Get-" cmdlets in the Microsoft* modules, output the results to a grid for interactive analysis.
# 1. Use Get-Command to retrieve Get- cmdlets in the Microsoft* modules
# 2. Pipe the results to Get-Help
# 3. Select name, synopsis, modulename properties from the help objects
# 4. Output the results to a GridView

#region " Solution for III "

Get-Command -Verb get -Module microsoft* | Get-Help | Select-Object name, synopsis, modulename | Out-GridView

#endregion

# piping data (objects)
Get-Service | Sort-Object Name
Get-Service | Sort-Object Name | Out-Gridview
Get-Service | Sort-Object Name | Select-Object * | Out-Gridview

Get-Service bit* -ComputerName (Get-Content \\fsnugget\psv4\files\servers.txt) |
    Sort-Object Name |
    Select-Object Name, Status, MachineName | 
    Format-List


# exporting
Get-Service win* | Where-Object Status -eq Running | Export-Csv services.csv
notepad services.csv

Get-Service win* | Where-Object Status -eq Running | ConvertTo-Html | Out-File services.html
start services.html


#-------------------------------------------------
# Challenges for PowerShell 4 Foundations: Objects
#-------------------------------------------------


#I: Examine the object members returned from Get-Process

#region

Get-Process | Get-Member

#endregion


#II: Write a pipeline to get processes where cpu utilization is greater than zero, return properties not shown in the default view, and sort the results by cpu descending.

#region

Get-Process | Where-Object CPU -gt 0 | Select-Object Name, CPU, Threads | Sort-Object CPU -Descending

#endregion


#III: Write a pipeline to find all .jpg and .png files created on a drive in the last 24 hours, copy them to another directory named backup.
#1. Get-ChildItem recursively with a filter for *.jpg, *.png against a drive.
#2. Where-Object against CreationTime property where it's greater than the current date (use AddHours(-24) on Get-Date).
#3. For-Each to iterate through the returned objects, using Copy-Item in the script block

#region

Get-ChildItem C:\ -Filter *.jpg, *.png -Recurse | Where-Object CreationTime -gt (Get-Date).AddHours(-24) | ForEach-Object {Copy-Item $_ -Destination '\\fsnugget\psv4\backup'}

#endregion

# get-member
help Get-Member
Get-Service | Get-Member

# properties
dir | gm
dir -Directory | gm
dir -Directory | Select Name, CreationTime, FullName
(dir -Directory).FullName
(dir desk* -Directory).CreateSubdirectory('test')

# methods
$today = Get-Date
$today | gm
$today.DayOfYear
$today.DayOfWeek
$today.AddDays(30)
$today.AddMonths(6)
(Get-Date).AddYears(10)

# static methods
[math] | gm
[math] | gm -static
[math]::pi
[math]::min(100, 10000)



# *-object cmdlets
Get-Command -Noun object


# where-object
Get-Service | Where-Object Status -eq "Running"
Get-Service | Where-Object {$_.Status -eq "Running"}
Get-Service | Where-Object {$_.Status -eq "Running" -and $_.CanStop}


# select-object
Get-Service | Select-Object *
Get-Service | Select-Object Name, Status, MachineName, ServiceType -First 5 -Unique
Get-ChildItem \\fsnugget\psv4\installs | Select-Object Name, Length, @{Name="MBs";Expression={$_.Length / 1Mb}}


# sort-object
Get-Childitem | Sort-Object Length -Descending -CaseSensitive


# foreach-Object
1,2,3,4 | ForEach-Object {$_ * 100}


dir c:\*.exe -recurse | where {$_.CreationTime.Year -eq (Get-Date).Year} | 
    % -Begin {Get-Date} `
      -Process {Out-File exe-log.txt -Append -InputObject $_.FullName} `
      -End {Get-Date}


# using -passthru
Get-ChildItem *.txt -ReadOnly -Recurse | Rename-Item -NewName {$_.BaseName + "-ro.txt"} -PassThru
