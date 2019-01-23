<#  
    .SYNOPSIS  
       Retrieves event logs pertaining to Windows Reboots via WMI.  
    .DESCRIPTION  
       Retrieves event logs pertaining to Windows Reboots via WMI between 2 dates provided by user. 
       Script runs/retrieves the data using the current logged in user credentials by default. 
       Creates 2 Logs, one with a Snapshot of all the restarts, scheduled vs unscheduled reboots and a full report with detailed information. 
    .EXAMPLE  
       The script needs a file with all the server names placed in a text file "Servers.txt" in the script root and can start executing directly. 
       PS > .\Restart_Audit.ps1 
  
    .NOTES  
       Author: Murali Palla 
       email: contact@muralipalla.com 
       Site: http://www.muralipalla.com/  
       Requires: Powershell 2.0  
  
       Version History  
       1.0.0 - 12/22/2014 
        - Initial release  
    #> 
$SourceFile = ".\Servers.txt" 
if(!(Test-Path $SourceFile)){Write-Host "Unable to find a File $SourceFile with list of Server Names";exit} 
$ServerList = (Get-Content .\Servers.txt)  
do { 
$Error.Clear() 
$result = 0 
[bool]$ValidStart = $false 
$StartingDay = Read-Host "Enter the Start date in MM/DD/YY Format" 
  if ((!([DateTime]::TryParse($StartingDay, [ref]$result))) -or ($Error.Count)) { 
        Write-Host "Your date $StartingDay was invalid. Please try again." 
        $ValidStart = $False 
    } 
    else{ 
        $ValidStart = $True 
        [datetime]$StartingDay=$StartingDay 
    } 
 
}until($ValidStart -eq $True) 
 
do { 
$Error.Clear() 
$result = 0 
[bool]$ValidEnd = $false 
$EndingDay = Read-Host "Enter the End date in MM/DD/YY Format" 
   if ((!([DateTime]::TryParse($EndingDay, [ref]$result))) -or ($Error.Count)) { 
        Write-Host "Your date $EndingDay was invalid. Please try again." 
        $ValidEnd = $False 
    } 
    else{ 
        $ValidEnd = $True 
        [datetime]$EndingDay=$EndingDay 
    } 
 
}until($ValidEnd -eq $True) 
 
$Collection = @() 
$Summary=@() 
foreach ($Server in $Serverlist)  
{ 
    Write-Output "Workgin on $Server" 
    $RestartCount=0 
    $ScheduledRebootCount=0 
    $UnscheduledRebootCount=0 
 
    $objEventLog = Get-WmiObject -ComputerName $Server -Class Win32_NTLogEvent -Filter " 
        (LogFile='System' and  
        TimeWritten>='$StartingDay' and  
        TimeWritten<='$EndingDay' ) and  
        (EventCode=1076 or EventCode=1074)" 
             
    ForEach ( $Event in $objEventLog ) 
    { 
    $EventCode = $Event.EventCode 
    $ServerName = $Event.ComputerName 
    $RestartCount++         
    [datetime]$TimeGenerated = [management.managementDateTimeConverter]::ToDateTime($Event.TimeGenerated) 
         
    if($EventCode -eq 1074){$RebootType = "Scheduled";$ScheduledRebootCount++}elseif($EventCode -eq 1076){$RebootType = "Un-Scheduled";$UnscheduledRebootCount++} 
                 
    $CollectionObject = New-Object -TypeName psobject 
        Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name ServerName -Value $ServerName 
        Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name EventCode -Value $EventCode 
        Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name RebootType -Value $RebootType     
        Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name TimeGenerated -Value $TimeGenerated 
        Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name User -Value $Event.User 
        Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name Message -Value $Event.Message 
    $Collection += $CollectionObject 
    } 
    if($RestartCount -eq 0) 
    { 
        $CollectionObject = New-Object -TypeName psobject 
            Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name ServerName -Value $Server 
            Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name EventCode -Value "N/A" 
            Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name RebootType -Value "N/A"     
            Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name TimeGenerated -Value "N/A" 
            Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name User -Value "N/A" 
            Add-Member -InputObject $CollectionObject -MemberType NoteProperty -Name Message -Value "N/A" 
        $Collection += $CollectionObject 
        $SummaryObject=New-Object -TypeName psobject 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name ServerName -Value $Server 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name RestartCount -Value $RestartCount 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name ScheduledReboots -Value $ScheduledRebootCount 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name UnscheduledReboots -Value $UnscheduledRebootCount 
        $Summary += $SummaryObject 
    } 
    else 
    { 
        $SummaryObject=New-Object -TypeName psobject 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name ServerName -Value $ServerName 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name RestartCount -Value $RestartCount 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name ScheduledReboots -Value $ScheduledRebootCount 
            Add-Member -InputObject $SummaryObject -MemberType NoteProperty -Name UnscheduledReboots -Value $UnscheduledRebootCount 
        $Summary += $SummaryObject 
    } 
} 
$CurrentDate = Get-Date 
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hh-mm-ss') 
$Summary | Export-Csv -Path .\"$CurrentDate`_SUmmary.CSV" -NoTypeInformation 
$Collection | Export-Csv -Path .\"$CurrentDate`_Detailed_Summary.CSV" -NoTypeInformation 
Write-Output "Reports saved to the below mentioned 2 files in the root of the script. 
"$CurrentDate`_Detailed_Summary.CSV"  
"$CurrentDate`_SUmmary.CSV"" 
Write-Output $Summary | Format-Table -AutoSize