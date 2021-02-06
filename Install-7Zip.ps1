<#
.Synopsis
   Short description
    This script will be used for installing silently 7Zip installer with getting latest version from its web.
.DESCRIPTION
   Long description
    2020-11-14 Sukri Created.
    2021-02-06 Sukri Imported some external functions.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
    Author : Sukri Kadir
    Email  : msmak1990@gmail.com
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

#include external functions from external PS script files.
. "$PSScriptRoot\Get-OSArchitecture.ps1"
. "$PSScriptRoot\Get-7ZipBinary.ps1"
. "$PSScriptRoot\Get-7Zip.ps1"

function Install-7Zip
{
    Param
    (

    #Parameter for 7Zip installer file name.
        [ValidateNotNullOrEmpty()]
        [String]
        $BinaryFileName = "7z1900-x64.msi",

    #Parameter for 7Zip installer source path or uri.
        [ValidateNotNullOrEmpty()]
        [String]
        $InstallerSourceDirectory = "https://sourceforge.net/projects/sevenzip/files/7-Zip/"
    )

    Begin
    {
        #validate if 7Zip installed or not from target system.
        $ApplicationInstallationStatus = Get-7Zip

        #throw the warning message if there had been installed from the target system.
        if ($ApplicationInstallationStatus[0] -eq $true)
        {
            Write-Warning -Message "[$( $ApplicationInstallationStatus[1] )] already installed." -WarningAction Continue
        }

        #if 7Zip is not installed from target system.
        if ($ApplicationInstallationStatus[0] -eq $false)
        {
            #if 7Zip installer source directory is local directory.
            if ($( Test-Path -Path $InstallerSourceDirectory -PathType Any ))
            {
                Write-Warning -Message "[$InstallerSourceDirectory] is local directory."

                #get full path of 7Zip binary file.
                $BinaryFile = "$InstallerSourceDirectory\$BinaryFileName"
            }

            #if 7Zip installer source directory is url.
            if (!$( Test-Path -Path $InstallerSourceDirectory -PathType Any ))
            {
                Write-Warning -Message "[$InstallerSourceDirectory] is url link." -WarningAction Continue

                #get full path of 7Zip binary file.
                $BinaryFile = Get-7ZipBinary -InstallerSourceUrl $InstallerSourceDirectory
            }
        }

    }
    Process
    {

        #if 7Zip is not installed from target system.
        if ($ApplicationInstallationStatus[0] -eq $false)
        {
            #install 7Zip binary.
            $InstallationProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $BinaryFile, "/passive", "/norestart" -Wait -NoNewWindow -Verbose -ErrorAction Stop

            #throw exception if failed to install 7Zip binary.
            if ($InstallationProcess.ExitCode -ne 0)
            {
                Write-Error -Message "[$BinaryFile] failed to install with exit code [$( $InstallationProcess.ExitCode )]." -ErrorAction Stop
            }
        }
    }
    End
    {
        #validate if the 7Zip already installed in the target system.
        #throw the warning message if there had been installed from the target system.
        if ($ApplicationInstallationStatus[0] -eq $true)
        {
            Write-Warning -Message "Final validation on checking the application ..."
            Write-Warning -Message "[$( $ApplicationInstallationStatus[1] )] already installed." -WarningAction Continue
        }
        Write-Host "Done."
    }
}

#log the logging into log file.
Start-Transcript -Path "$PSScriptRoot\$( $MyInvocation.ScriptName )"

#execute the function.
Install-7Zip

#stop to log the logging.
Stop-Transcript