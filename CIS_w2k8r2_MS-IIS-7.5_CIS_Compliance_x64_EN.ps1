#w2k8r2_MS-IIS-7.5_CIS_Compliance_x64_EN

Function GetOSVersion {
	$OS=gwmi win32_operatingsystem
	Return $OS.Version.substring(0,3)
}

function SetCISLevelOne {
	Write-Host "INFO:  Starting CIS IIS 7 Level One Compliance Checks"
	If (!(Get-module WebAdministration)) {
        Import-Module WebAdministration
	}
	#1.1.8 Configure Anonymous User Identity to Use Application Pool Identity
	#sets userName attribute of the anonymousAuthentication tag to a blank string
	$useridentity = Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/security/authentication/anonymousAuthentication" -name userName 
    
	if ($useridentity.Value -eq "") { Write-Host "INFO:  Application Pool Identity already set to Anonymous User, continuing script"}
	else {
    	Write-Host "INFO:  Setting Application Pool Identity to Anonymous User"
		Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/security/authentication/anonymousAuthentication" -name "userName" -value ""
		Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/security/authentication/anonymousAuthentication" -name "password" -value ""
    	Write-Host "INFO:  Application Pool Identity has been successfully changed to Anonymous User"
    }
	#1.1.10 Stop non-used Application Pools	(Cannot be changed due to breaking viewing of default webpage, see https://confluence.savvis.net/display/ENGPUB/CIS+Level+One+Microsoft+IIS+7)
    
	#1.3.8 Configure Global .NET Trust Level
	$trustlevel = Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT'  -filter "system.web/trust" -name level

	if ($trustlevel.Value -eq "Medium") { Write-Host "INFO:  Global .Net Trust Level is already set to Medium, continuing script"}
	else {
    	Write-Host "INFO:  Setting Global .Net Trust Level to Medium"
		Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT'  -filter "system.web/trust" -name "level" -value "Medium"
    	Write-Host "INFO:  Global .Net Trust Level is now set to Medium"
    }    	
	#1.4.6 Disallow Unlisted File Extensions (Cannot be changed due to breaking other managed apps, see https://confluence.savvis.net/display/ENGPUB/CIS+Level+One+Microsoft+IIS+7)
	
	#1.4.10 Disable HTTP Trace Method
	#adds Deny Verb with value "TRACE" in Request Filtering section
	$verbfilter = Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/security/requestFiltering/verbs" -name .
	if ($verbfilter.Collection) { Write-Host "INFO:  Request Filtering Verb Option is already set to Deny the Verb TRACE, continuing script"}
	else {
    	Write-Host "INFO:  Setting Request Filtering Verb Option to Deny the Verb TRACE"	
    	Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/security/requestFiltering/verbs" -name "." -value @{verb='TRACE';allowed='False'}
    	Write-Host "INFO:  Request Filtering Option has been successfully changed to Deny the Verb TRACE"	
    }

}

function SetDeploymentMethod {
	#1.3.1 Set Deployment Method to Retail 
	param ([System.String]$path)
	
	#gets path of current .net being used, in Opsware Console it's v4.0.30319, in Powershell console it's v2.0.50727 
	$path = [System.Runtime.InteropServices.RuntimeEnvironment]::SystemConfigurationFile;
	$path32 = "";
	$path64 = "";
	
	if ($path.Contains("Framework64")) {
    	#sets 64-bit .net machine.config path
    	$path32 = $path.Replace("Framework64", "Framework");
    	$path64 = $path;
	}
	else
	{
    	#sets 32-bit .net machine.config path
    	$path32 = $path;
    	$path64 = $path.Replace("Framework", "Framework64");
	}

	#if .backup file doesn't exist, backup original 64-bit .Net machine.config file and replace string
	if (!(test-path "$path64.backup")){
    	$xml64 = [xml](get-content($path64))
    	$xml64.Save($path64+ ".backup")
    	Write-Host "INFO:  Backing up 64-bit .Net Machine.config file $path64"
    	Write-Host "INFO:  64-bit .Net Machine.config update started"
    	$xml64 = (get-content($path64))
    	$xml64 = $xml64 -replace "<system.web>", '<system.web> 
                    <deployment retail="true" />' | set-content $path64
    	Write-Host "INFO:  Saving original 64-bit .net machine.config file with <deployment retail=""true""/> update"
	}
	else {Write-Host "INFO:  64-bit machine.config.backup exists, continuing script"}

	#if .backup file doesn't exist, backup original 32-bit .Net machine.config file and replace string
	if (!(test-path "$path32.backup")){
    	$xml32 = [xml](get-content($path32))
    	$xml32.Save($path32+ ".backup")
    	Write-Host "INFO:  Backing up 32-bit .Net Machine.config file $path32"
    	Write-Host "INFO:  32-bit .Net Machine.config update started"
    	$xml32 = (get-content($path32))
        $xml32 = $xml32 -replace "<system.web>", '<system.web> 
                    <deployment retail="true" />' | set-content $path32
     	Write-Host "INFO:  Saving original 32-bit .net machine.config file with <deployment retail=""true""/> update"
	}
	else {Write-Host "INFO:  32-bit machine.config.backup exists, continuing script"}
    Write-Host "INFO:  Finished with CIS IIS 7 Level One Compliance Checks"
}

function Main {
	[string]$OS = GetOSVersion
	If ($OS -ne 6.1) {
		[Console]::Error.WriteLine("ERROR: You are running this script against a non-Windows 2008R2 OS")
		Exit 99
	}
	SetCISLevelOne
	SetDeploymentMethod
}
Main
Write-Host "INFO ---------------------------------------------------------------------------------------"
#Ver 1
