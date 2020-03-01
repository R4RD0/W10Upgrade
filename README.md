## W10Upgrade
![GitHub All Releases](https://img.shields.io/badge/Powershell-2.0-green)
### Windows 7 & Windows 10 In Place Upgrade

  This script should be able to run a few key checks and upgrade any device from windows 7 to windows 10 (version depends on your ISO) 
  Checking the target device for its PSversion and Drive space.
  Downloads the ISO from the location specified and 3rd part tools if required.
  Mounts ISO and kicks off the install command, from this point onwards it's all up to the Device itself.
  
  This will only work with a authenticated version of windows.
  
  The ISO can be sourced from the Media Creation Tool https://www.microsoft.com/en-gb/software-download/windows10 - always the latest version (currently 1909)
  ISOs sourced from the Media Creation Tool and Retail versions seem to work (untested with preview versions).

The 3rd party tool currently set is available from https://github.com/sysprogs/WinCDEmu "PortableWinCDEmu-4.0.exe" - best to be self hosted as pulling straight from GitHub will fail due to delayed response from the site.


### Passable Peramiters

URL, URLWinCDm, LocalPath, LogPath, MinSpace
Or just set the defualt loadout in the Peram block.

```markdown
Param(
    [Parameter(Mandatory = $false)] 
    [String]$URL = "http://Enter.YourOwnWebHost.com/windows10.iso";, #pre defined URL for ISO
    [String]$URLWinCD = "http://Enter.YourOwnWebHost.com/PortableWinCDEmu-4.0.exe";, #WinCDEmu to mount the ISO
    [String]$localpath = "C:\Temp", # predefine local path to save ISO - IMPORTANT No trailing "\"
    [int]$minspace = 30, # Minimum free HDD Space Required
    [string]$logpath = "C:\Temp" # Logs turned off if folder not specified.
)

```

### Usage Examples
>.\w10u.ps1 -URL "http://website.com/deploy/windows10.iso" -URLWinCD "http://website.com/deploy/PortableWinCDEmu-4.0.exe" 

