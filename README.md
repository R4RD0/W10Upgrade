## W10Upgrade

This is a script to download Windows 10 ISO (self Hosted) and mount it withing windows 7 to then perform an in-place upgrade. 

### Markdown

This script can take some basic peramiters for the hostl location, local location and minimum space.

```markdown
Param(
    [Parameter(Mandatory = $false)] 
    [String]$URL = "http://Enter.YourOwnWebHost.com/windows10.iso";, #pre defined URL for ISO
    [String]$URLWinCD = "https://s3.eu-west-2.amazonaws.com/de.rar.do/dl/PortableWinCDEmu-4.0.exe";, #WinCDEmu to mount the ISO
    [String]$localpath = "C:\Temp", # predefine local path to save ISO - IMPORTANT No trailing "\"
    [int]$minspace = 30, # Minimum free HDD Space Required
    [string]$logpath = "C:\Temp" # Logs turned off if folder not specified.
)

```


### Support or Contact

One can try and help where possible
