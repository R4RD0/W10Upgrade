#requires -version 2
<#
.SYNOPSIS
  Windows10 Deployment 
  Download, Mount (use 3rd party tool), Run the Upgrade Silently.

.DESCRIPTION
  This script should be able to run a few key checks and upgrade any device from windows 7 to windows 10 (version depends on your ISO) 
  Checking the target device for its PSversion and Drive space.
  Downloads the ISO from the location specified and 3rd part tools if required.
  Mounts ISO and kicks off the install command, from this point onwards it's all up to the Device itself.
  
  The ISO can be sourced from the Media Creation Tool https://www.microsoft.com/en-gb/software-download/windows10 - always the latest version (currently 1909)
  ISOs sourced from the Media Creation Tool and Retail versions seem to work (untested with volume license and preview versions).

  The 3rd party tool currently set is available from https://github.com/sysprogs/WinCDEmu "PortableWinCDEmu-4.0.exe" - best to be self hosted as pulling straight from GitHub will fail due to delayed response from the site.


.PARAMETER URL
    Insert your one URL for the Windows10 ISO
.PARAMETER URLWINCD
    Insert your own host location for the WinCDEmu Mounting tool.
.PARAMETER LOCALPATH
    This will be the Download and working directory for the install. Defaults to C:\Temp
.PARAMETER MINSPACE
    Define your own minimum space requirement
      - Windows 10 likes to have 20GB free
      - ISO download will require 6-8GB
      - Rounding up: Recommended 30GB free
            with 30gb free before installing and compacting, there will be 16gb free afterwards.
.PARAMETER LOGPATH
    Logfile location, Local or network(if permissions allow). Folder Only. Script Log and Windows upgrade log will be copied to here. 

.NOTES
  Version:        1.4
  Author:         Luke Cutmore
  Company:        Dynamic Edge
  Creation Date:  12/02/2020
  Purpose/Change: final cleanup and release

#>
#region--------------------------------------------------[Initialisations]-------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"

Param(
    [Parameter(Mandatory = $false)] 
    [String]$URL = "http://Enter.YourOwnWebHost.com/windows10.iso";, #pre defined URL for ISO
    [String]$URLWinCD = "https://s3.eu-west-2.amazonaws.com/de.rar.do/dl/PortableWinCDEmu-4.0.exe";, #WinCDEmu to mount the ISO
    [String]$localpath = "C:\Temp", # predefine local path to save ISO - IMPORTANT No trailing "\"
    [int]$minspace = 30, # Minimum free HDD Space Required
    [string]$logpath = "C:\Temp" # Logs turned off if folder not specified.
)
#endregion
#region --------------------------------------------------[Declarations]---------------------------------------------------------

#Hostname
$Hostname = "$(Get-Content env:computername)"

#--------------- Pesky UAC ---------------#
#Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

#--------------- Log File Info ---------------#
if (!($logpath -eq "")){
  $logpath = $logpath
  $cmdlog = " /CopyLogs $logpath"
  $Date = get-date -format "yyyy-MM-dd_HHmmss"
  $LogName = "Win10DeployScript_$Hostname"+"_$date.log"
  $LogFile = Join-Path -Path $LogPath -ChildPath $LogName
}
$global:setupPath = ""
#---------------OS data ---------------#
$1 = $(((Get-WMIObject win32_operatingsystem).name).split('|'[0]))
$2 = $((Get-WMIObject win32_operatingsystem).CSName) 
$3 = $((Get-WMIObject win32_operatingsystem).OSArchitecture) 
$winver = "$1 $2 $3"
#endregion
#region ---------------------------------------------------[Functions]-----------------------------------------------------------
#---------------- Write Logs ---------------#
Function LogWrite{
   Param ([string]$logstring)
   if (!($logpath -eq "")){  #bool
   $Date = get-date -format "yyyy-MM-dd HH:mm:ss" #fresh date/time
   Add-content $Logfile -value "$Date `| $logstring"
   write-host $logstring
  }
}
#---------------Checking free space ---------------#
Function CheckSpace {
  LogWrite -logstring "Checking Storage Space"
    $Drive = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '3'" |
    Select-Object -Property DeviceID,@{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}}| 
    Where-Object {$_.DeviceID -eq 'C:'} | Select-Object FreeSpaceGB
    if (($Drive.FreeSpaceGB -as [double]) -lt ($MinSpace -as [double]))
    {
      LogWrite -logstring "ISSUE: Storage space does not meet requirements"
      LogWrite -logstring "Error: Please ensure there is at least $MinSpace GB available." -ForegroundColor Red

        return $False
    }
    else
    {
      LogWrite -logstring "Success: Over $MinSpace GB available. - Continuing"
        return $true
    }
}
#--------------- Check PS Version ---------------#
Function PSversionCheck {
  $Ver = "$($PSVersionTable.PSversion.Major)"+"."+"$($PSVersionTable.PSversion.minor)"
    if (($PSVersionTable.PSversion.major) -gt 3)
    { 
      LogWrite -logstring "Success: Powershell Version $ver"
        return $true
    }
        else
    {
      LogWrite -logstring "Failed: Powershell Version $ver"
        return $False
    } 
}
#--------------- Working area ---------------#
#needs to run before we can have a Log saving lcoation.
Function CreateLocalPath {
if (!(Test-Path -LiteralPath $localpath)) {
  try {
      New-Item -Path $localpath -ItemType Directory -force -ErrorAction Stop | Out-Null #-Force
      New-Item -Path $logpath -ItemType Directory -force -ErrorAction Stop | Out-Null #-Force
      LogWrite -logstring "Log Path Created"
  }
  catch {
      Write-Error -Message "Unable to create '$localpath'. Error was: $_" -ErrorAction Stop
      Return false
  }
  LogWrite -logstring "Successfully created '$localpath'."
  return $true
}
else {
  LogWrite -logstring "$localpath already exists"
  return $true
}
}

#--------------- Downloads ---------------#
Function DownloadISO {
  if ([System.IO.File]::Exists("$LocalPath\windows10.ISO")){
    LogWrite -logstring "OLD Windows 10 ISO Already Exists - Deleting Old copy"
    [System.IO.File]::Delete("$LocalPath\windows10.ISO")
    LogWrite -logstring "OLD Windows 10 ISO Deleted"
  }
LogWrite -logstring "Windows 10 ISO Download Started"
  (New-Object system.Net.WebClient).DownloadFile($URL, "$LocalPath\windows10.ISO");
LogWrite -logstring "Windows 10 ISO Download Complete"
}


Function DownloadWinCD {
LogWrite -logstring "WinCDEmu Download Started"
  (New-Object system.Net.WebClient).DownloadFile($URLWinCD, "$LocalPath\PortableWinCDEmu-4.0.exe");
LogWrite -logstring "WinCDEmu Download Complete"
}

#--------------- Beta Install ---------------#
Function Beta{
  DownloadISO
  DownloadWinCD
  LogWrite -logstring "Installing WinCDEmu Drivers"
  $install = "$localpath\PortableWinCDEmu-4.0.exe /install" # /uninstall to remove drivers as and when thats required
  LogWrite -logstring $install
  
  try {cmd.exe /c $install
  LogWrite -logstring "Sleeping 3 #just to be sure"
  start-sleep 3 #just to be sure we'll delay
  }
  catch{
    LogWrite -logstring "$_"}

    LogWrite -logstring "Randomly selecting a drive Letter"
  $letter = Get-ChildItem function:[a-z]: -n | Where-Object{ !(test-path $_) } | get-random # get a random drive letter
  [string]$X = $letter[0]
  LogWrite -logstring "And the winner is Letter $X" 

  try{
  LogWrite -logstring  "Mounting ISO to drive $X"
  $mountString = "$localpath\PortableWinCDEmu-4.0.exe `"$localpath\Windows10.iso`" $X /wait"
  LogWrite -logstring $mountString
  cmd.exe /c $mountString
  LogWrite -logstring "Sleeping 2"
  start-sleep 2}
  catch {LogWrite -logstring "Mounting Error"
  LogWrite -logstring "$_"}
  finally{
    If (!($LASTEXITCODE)){
      LogWrite -logstring "Successfully Mounted the ISO"
    }else {
      LogWrite -logstring "Failed to mount the ISO (may already be mounted)"
    }
  }
  $global:setupPath = $letter
  LogWrite -logstring "$global:setupPath"
}

#--------------- Command String ---------------#
function makecommandstring{
  $Global:CommandString = "$global:setupPath\setup.exe /auto upgrade /quiet /migratedrivers all /ShowOOBE none /Telemetry Disable /Compat IgnoreWarning$cmdlog" #  /DynamicUpdate Disable
  logwrite -logstring "$Global:CommandString"
}
#endregion
#region ---------------------------------------------------[Execution]-----------------------------------------------------------
CreateLocalPath
LogWrite -logstring "W10U Automation"
LogWrite -logstring "$winver"
LogWrite -logstring "Starting Checks"
LogWrite -logstring "===================="
if (!(CheckSpace)){
  LogWrite -logstring "Error: Space - Exiting"
  LogWrite -logstring "===================="
  EXIT 0
}
LogWrite -logstring "Switching to WinCDEmu"
Beta
LogWrite -logstring "Confirm Command String:"
makecommandstring
LogWrite -logstring "Sleeping 3"
start-sleep 3
LogWrite -logstring "Running the final command"
try{cmd.exe /c $Global:CommandString}
Catch{LogWrite -logstring "Command failure : $_"}
finally{LogWrite -logstring "===================="}
LogWrite -logstring "All Commands completed. Device is on its own from here on"
LogWrite -logstring "===================="
start-sleep 3
Exit "Complete"
#endregion
#-----------------------------------------------------------[The End]------------------------------------------------------------
