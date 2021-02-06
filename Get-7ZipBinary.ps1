<#
.Synopsis
   Short description
    This script will be used for downloading the latest 7Zip installer from its official site.
.DESCRIPTION
   Long description
    2021-02-06 Sukri Created.
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
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

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
        #final validation to check the download directory.
        if (!$( Test-Path -Path $InstallerDownloadDirectory -PathType Leaf ))
        {
            Write-Error -Message "[$InstallerDownloadDirectory] does not exist." -Category ObjectNotFound -ErrorAction Stop
        }

        #return full path for 7Zip installer binary file.
        return $InstallerDownloadDirectory
    }
}