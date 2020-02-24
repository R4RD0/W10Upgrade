## W10Upgrade

  This script should be able to run a few key checks and upgrade any device from windows 7 to windows 10 (version depends on your ISO) 
  Checking the target device for its PSversion and Drive space.
  Downloads the ISO from the location specified and 3rd part tools if required.
  Mounts ISO and kicks off the install command, from this point onwards it's all up to the Device itself.
  
  The ISO can be sourced from the Media Creation Tool https://www.microsoft.com/en-gb/software-download/windows10 - always the latest version (currently 1909)
  ISOs sourced from the Media Creation Tool and Retail versions seem to work (untested with volume license and preview versions).

The 3rd party tool currently set is available from https://github.com/sysprogs/WinCDEmu "PortableWinCDEmu-4.0.exe" - best to be self hosted as pulling straight from GitHub will fail due to delayed response from the site.


### Details
| Order of action       | Default result |
| ------------- |------------- |
| Check drive space of C       | Error and Exit if too low.|
| Check/Create Temp folder     | Skip if exists |
| Create Logs | Set date/time and hostname - create log file |
| Download ISO and WinCD | Delete if already exists to ensure latest non corrupt version |
| Install driver for WinCD | /install (/uninstall optional)
| Mount ISO  | Randomly select a drive letter and mount the ISO to it.
| Set the Command String for setup.exe | throw the drive letter and log folder in to the setup string |
| Run it | calls setup.exe and closes the script. |


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


### Support or Contact

One can try and help where possible
