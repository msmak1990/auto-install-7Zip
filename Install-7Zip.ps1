<#
.Synopsis
   Short description
    This script will be used for installing silently 7Zip installer with getting latest version from web.
.DESCRIPTION
   Long description
    2020-11-14 Sukri Created.
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

function Get-OSArchitecture
{
    Param
    (
    #parameter for query statement for OS Architecture.
        [ValidateNotNullOrEmpty()]
        [String]
        $QueryOSArchitecture = "Select OSArchitecture from Win32_OperatingSystem"
    )

    Begin
    {
        #get OS Architecture.
        $OSArchitecture = (Get-WmiObject -Query "Select OSArchitecture from Win32_OperatingSystem").OSArchitecture
    }
    Process
    {
        #identify which OS Architecture.
        if ($OSArchitecture)
        {
            #for 64-bit OS Architecture.
            if ($OSArchitecture -eq "64-bit")
            {
                $OSArchitectureBit = $OSArchitecture
            }

            #for 32-bit OS Architecture.
            if ($OSArchitecture -ne "64-bit")
            {
                $OSArchitectureBit = $OSArchitecture
            }
        }

        #return null if OS Architecture is empty.
        if (!$OSArchitecture)
        {
            $OSArchitectureBit = $null
        }
    }
    End
    {
        #return true if values available.
        if ($OSArchitectureBit)
        {
            return $true, $OSArchitectureBit
        }

        #return true if values available.
        if ($OSArchitectureBit)
        {
            return $false
        }
    }
}

function Get-7ZipBinary
{
    Param
    (
    #parameter for 7Zip installer source url.
        [ValidateNotNullOrEmpty()]
        [String]
        $InstallerSourceUrl
    )

    Begin
    {
        #create the request.
        $HttpRequest = [System.Net.WebRequest]::Create($InstallerSourceUrl)

        #get a response from the site.
        $HttpResponse = $HttpRequest.GetResponse()

        #get the HTTP code as an integer.
        $HttpStatusCode = [int]$HttpResponse.StatusCode

        #throw exception if status code is not 200 (OK).
        if ($HttpStatusCode -ne 200)
        {
            Write-Error -Message "[$InstallerSourceUrl] unable to reach out with status code [$HttpStatusCode]." -ErrorAction Stop
        }

        #get OS architecture - 32 or 64-bit?.
        $OSArchitecture = Get-OSArchitecture

    }
    Process
    {
        #get site contents.
        $SiteContents = Invoke-WebRequest -Uri $InstallerSourceUrl -UseBasicParsing

        #get href link.
        $SiteHrefs = $SiteContents.Links

        #dynamic array for storing 7Zip version extracted from site.
        $ApplicationVersion = [system.Collections.ArrayList]@()

        #filter only uri contains the 7Zip versions.
        foreach ($SiteHref in $SiteHrefs)
        {
            if ($SiteHref.href -match "/projects/sevenzip/files/7-Zip/\d.*/$")
            {
                $UrlVersion = $SiteHref.href -replace "/projects/sevenzip/files/7-Zip/", ""
                $VersionNumber = $UrlVersion -replace "/", ""
                $ApplicationVersion.Add($VersionNumber) | Out-Null
            }
        }

        #get latest 7Zip installer version.
        $LatestApplicationVersion = $ApplicationVersion[0]

        #remove space from installer version.
        $VersionNumberWOSpace = $( $LatestApplicationVersion -replace "\.", "" )

        #get OS architecture for 7Zip binary file name.
        if ($OSArchitecture[0] -eq $true)
        {
            #for 32-bit
            if ($OSArchitecture[1] -eq "32-bit")
            {
                #get latest 7Zip binary file name.
                $BinaryFileName = "7z$VersionNumberWOSpace.msi"
            }

            #for 64-bit
            if ($OSArchitecture[1] -eq "64-bit")
            {
                #get latest 7Zip binary file name.
                $BinaryFileName = "7z$VersionNumberWOSpace-x64.msi"
            }
        }

        #if no available for OS Architecture, then use 32-bit 7Zip binary file name.
        if ($OSArchitecture[0] -eq $false)
        {
            #get latest 7Zip binary file name.
            $BinaryFileName = "7z$VersionNumberWOSpace.msi"
        }


        #get full path of 7Zip binary source url.
        $BinarySourceUrl = "$InstallerSourceUrl/$( $LatestApplicationVersion )/$7ZipFileName/download"

        #get 7Zip download destination directory for specific user.
        $InstallerDownloadDirectory = "$( $env:USERPROFILE )\Downloads\$BinaryFileName"

        #download latest 7Zip binary file from site.
        Invoke-WebRequest -Uri $BinarySourceUrl -OutFile $InstallerDownloadDirectory -Verbose -TimeoutSec 60

        #throw exception if no available for 7Zip installer.
        if (!$( Test-Path -Path $InstallerDownloadDirectory -PathType Leaf ))
        {
            Write-Error -Message "[$InstallerDownloadDirectory] does not exist." -Category ObjectNotFound -ErrorAction Stop
        }
    }
    End
    {
        if (!$( Test-Path -Path $InstallerDownloadDirectory -PathType Leaf ))
        {
            Write-Error -Message "[$InstallerDownloadDirectory] does not exist." -Category ObjectNotFound -ErrorAction Stop
        }

        #return full path for 7Zip installer binary file.
        return $InstallerDownloadDirectory
    }
}


function Get-7Zip
{
    Param
    (
    #Parameter for registry path for installed software..
        [ValidateNotNullOrEmpty()]
        [Array]
        $UninstallRegistries = @("HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
    )

    Begin
    {
        #throw exception if registry path is not available.
        foreach ($UninstallRegistry in $UninstallRegistries)
        {
            #write warning if only not exist.
            if (!$( Test-Path -Path $UninstallRegistry -PathType Any ))
            {
                Write-Warning -Message "[$UninstallRegistry] does not exist." -WarningAction Continue
            }

        }
    }
    Process
    {
        #recusively search 7Zip through registry key.
        foreach ($UninstallRegistry in $UninstallRegistries)
        {
            #get 7Zip registry properties.
            $RegistryProperties = Get-ItemProperty -Path "$UninstallRegistry\*"

            foreach ($RegistryProperty in $RegistryProperties)
            {
                if ($( $RegistryProperty.DisplayName ) -like "*7-Zip*")
                {
                    $ApplicationName = $( $RegistryProperty.DisplayName )
                }
            }

        }
    }
    End
    {
        #return true if 7Zip installed in target system.
        if ($ApplicationName)
        {
            return $true, $ApplicationName
        }

        #return false if no 7Zip installed in target system.
        if (!$ApplicationName)
        {
            return $false
        }
    }
}

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
        Write-Host "Done."
    }
}

Install-7Zip
