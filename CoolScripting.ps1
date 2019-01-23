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

# validation sets
[validateset]

$services = Get-Service
$services.count
$services[1..5]

# switch statements
$status = 4

$status_text = Switch ($status) {
    0 { 'ok' }
    1 { 'nope' }
    2 { 'yea' }
    3 { 'keep trying' }
    default { 'you loser' }
}
$status_text

# looping through objects
1..100 | ForEach-Object -Process {start calc}

# use invoke-command when doing loops as this technique uses parallelism, not serialization
# control + j will show snippet examples 
# write-verbose use it, requires -verbose to enable it
# foreach best practice example $c in $computername
# PowerShell best practice use singular names in all scripts
# control + h (use this to replace all variables in ISE)
# hashtables by default are not ordered by any name, inv v3 use $c=[ordered]@{}
# use hashtables for simple scripts, for more advanced create new objects, ex. $obj=New-Object TypeName PSObject -Propery  $Prop
# don't use write-host, use write-output
# use ValidatePattern() for parameter binding validation sets, regular expressions
# for help, use -ShowWindow to display help with search function
# use Validate-Script

# ERROR HANDLING
# to see all type of error actions, type dir variable:*pref*
# examples for error action
Get-WmiObject win32_bios -ComputerName localhost, not
Get-WmiObject win32_bios -ComputerName localhost, not -EA SilentlyContinue -EV MyError
$MyError | out-file C:/xfer

# use try catch codeblocks for error handling, and write-warning on catch, then use $CurrentError to view errors
# use -whatif and -verbose when making any changes, example
# [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
# if ($pscmdlet.ShouldProcess("$Computername")
# if you notice a bug, go to connect and log it






