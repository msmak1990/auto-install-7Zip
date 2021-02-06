# auto-install-7Zip
* 2020-11-16 Sukri Created.
* 2020-11-16 Sukri Added on what script does.
* 2020-11-16 Sukri Added on how to run the script.
* 2020-11-16 Sukri Added its function descriptions.
* 2021-02-06 Sukri Imported the external modules into the main script.
---

### Description:
> * This is PowerShell script to install silently the 7-Zip binary (Windows 10 + PS ver5.1.x) by getting the latest version from the 7-Zip site. All done by automated way.

---

### Below are steps on what script does:

1. Identify the Operating System (OS) architecture for the target system (Windows platform that you want to install with 7-Zip) - i.e.: 32-bit or 64-bit.
2. Pre-validate the 7-Zip application (either installed or not) in the target system. If not yet installed, then proceed to download at step #3
3. Download the latest 7-Zip binary file from its site and temporarily locate into C:\Users<userprofile>\Downloads
4. Install silently the 7-Zip binary in the target system.
5. Post-validate the 7-Zip application (either installed or not) in the target system.
---  

### How to run this script.

1. Go to the cloned directory which contains both the Install-7Zip.cmd and Install-7Zip.ps1 files.
2. Double click on Install-7Zip.cmd file.

Note: both of files need to locate the same directory or folder.

---

### There are four functions involved:

1. Get-OSArchitecture
> * This function used for identifying OS architecture for the target system (Windows platform) i.e.: 32-bit or 64-bit
> * Details:

2. Get-7Zip
> * This function used for validating the existing of installed 7-Zip from target system.

3. Get-7ZipBinary
> *  This function used for downloading the latest version of 7-Zip from its site.
4. Install-7Zip

> * This function used for installing silently the 7-Zip binary from temporary download directory. i.e.: C:\Users\\[UserProfile]\Downloads
