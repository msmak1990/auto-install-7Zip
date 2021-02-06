# auto-install-7Zip
Date | Modified by | Remarks
:----: | :----: | :----
2020-11-16 | Sukri | Created.
2020-11-16 | Sukri | Added on what script does.
2020-11-16 | Sukri | Added on how to run the script.
2020-11-16 | Sukri | Added its function descriptions.
2021-02-06 | Sukri | Imported the external modules into the main script.
---

## Description:
> * This is the PowerShell script to install **silently** the 7-Zip binary by getting the latest version from the 7-Zip site. 
> * All done by automated way!.

Windows Version | OS Architecture | PowerShell Version | Result
:----: | :----: | :----: | :----
Windows 10 | 64-bit and 32-bit | 5.1.x | Tested. `OK`

---

### Below are steps on what script does:

No. | Steps
:----: | :----
1. | Identify the Windows Operating System (OS) architecture in the target system (i.e. 32-bit or 64-bit).
2. | Pre-validate the 7-Zip application in the target system (either installed or not).
3. | Throw the warning message if the target system already installed with the 7-Zip application and show its current version as well.
4. | Download the latest 7-Zip installer from its official site and temporarily save to `C:\Users\<userprofile>\Downloads`
5. | Install **silently** the 7-Zip installer in the target system.
6. | Post-validate the 7-Zip application in the target system to check the installation was successfully installed.
---  

### How to run this script.

1. Go to the cloned directory which contains both the `Install-7Zip.cmd` and `Install-7Zip.ps1` files.
2. Double click on `Install-7Zip.cmd` file.

**_Note: both of files need to locate the same directory or folder._**

---

### There are some functions involved as follows:

No. | Function Name | Description
:----: | :---- | ----
1. | Get-OSArchitecture | This function used for identifying the Windows OS architecture for the target system ( i.e. 32-bit or 64-bit ).
2. | Get-7Zip | This function used for validating the existing of installed 7-Zip from target system.
3. | Get-7ZipBinary | This function used for downloading the latest version of 7-Zip from its official site.
4. | Install-7Zip | This function used for installing *silently* the 7-Zip application from temporary download directory. i.e.: `C:\Users\<UserProfile>\Downloads`