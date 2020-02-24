## W10Upgrade

This is a script to download Windows 10 ISO (self Hosted) and mount it withing windows 7 to then perform an in-place upgrade. 

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
