Param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$fileContainingHash)
# Param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$fileContainingHash, [Parameter(Mandatory=$true, ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$folderContainingFiles) # 090221 previous script version
<#Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $fileContainingHash, 
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $folderContainingFiles
)#>
# Date created: Mar 2020
# Author: jack
# Last modified: Feb 2021
# Notes: 
# 1. Purpose: Check hash of ebooks. Modified to check if duplicate pdf, epub, zip or other files are present.

Write-Output "***** Starting Ps Script *****`nStart compute hash and comparing of files."

# ***** ***** ***** ***** *****

# $fileOfHashes = Get-Content "D:\folderPathToRootOfStorageLocation\other\{{bundleBeingChecked}}\md5Sums_all({{bundleBeingChecked}}).txt"
$fileOfHashes = Get-Content $fileContainingHash
$fileOfHashesTextLowered = $fileOfHashes.ToLower()

# $folderOfFiles = $folderContainingFiles # 090221 previous script version
$folderOfFiles = $fileContainingHash.Substring(0, $fileContainingHash.LastIndexOf("\") )
# e.g. 2 lines for testing without inputs setup at start of script
# $folderOfFiles = "D:\folderPathToRootOfStorageLocation\other\{{bundlePlaceholder}}"
# $folderOfFiles = "D:\download_staging\TOBMM\ff"

$resultOfCheckSums = @{}
Function AddChecksumResultToHashTable { # basically dont use myMethod() & Param options together. err: 'The param statement cannot be used if arguments were specified in the function declaration.'
# stackoverflow: 4988226/how-do-i-pass-multiple-parameters-into-a-function-in-powershell ans by user2233949(lots of explanation & demo)
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$fileName, 
        [Parameter(Mandatory=$true, Position=1)]
        [string]$fileHash
    )
    try {
        # $tempString = $_.Path.Substring($_.Path.LastIndexOf("\") + 1)
        Write-Output $fileName
        $resultOfCheckSums.Add($fileName, $fileHash)
    } catch {
        Write-Warning $_.Exception
        Write-Warning "ATTEMPT TO ADD DUPLICATE KEY INTO HASHTABLE"
        # $resultOfCheckSums.Add("ERROR: $($_.Path)", "duplicate file in this bundle")
    }
}

$numHashesMatchedIndex = 0

$postMay2022_NoHashOnBundlePage = $fileOfHashesTextLowered[0]
if ($postMay2022_NoHashOnBundlePage -contains "NOHASH ON BUNDLE PAGE") {
    Write-Output "`nThis text file does not contain the MD5 hashes. `nInstead of ensuring each downloaded file has corresponding hash in text file, `nreport on any files that have not been downloaded..."

    foreach($lineText in $fileOfHashesTextLowered) {
        # Nov 2022 skip 1st line else "NOHASH ON BUNDLE PAGE" is treated as file name search causing erroneus CLI warning "WARNING: nohash on bundle page has not been downloaded!"
        if ($lineText -contains "NOHASH ON BUNDLE PAGE") {
            continue
        }

        if ($lineText.Length -ne 0) {

            $ebookFileName = $lineText.Substring($lineText.LastIndexOf("/") + 1)
            $booleanFileDownloaded = Get-ChildItem -Path $folderOfFiles -recurse -filter $ebookFileName -File 
            if ($booleanFileDownloaded -eq $null) {
                Write-Warning "$($ebookFileName) has not been downloaded!"
            } 
            # not required unless want to see output in powershell CLI that file has been downloaded
            # else {
            #     Write-Output "$($ebookFileName) has been downloaded!"
            # }
        }
    }
}
else {
Get-ChildItem -Path $folderOfFiles -Recurse | 
%{Get-FileHash $_.FullName -Algorithm MD5} | 
%{
    # $numHashesMatchedIndex = 0 # initializing the variable here results in '1' printed repeatedly as reinit for each
    # pipeline item sent through previous action, i.e. before |

    $boolHashFound = $false
    foreach($lineText in $fileOfHashesTextLowered) {
        
        if ($lineText.Length -ne 0) {
            if ($lineText.ToString().Substring(0, 32) -contains $_.Hash.ToLower()) {
                $numHashesMatchedIndex++
                $boolHashFound = $true

            } 
        }
    }
    if ($boolHashFound) {
        $fileNameInput = $_.Path.Substring($_.Path.LastIndexOf("\") + 1)
        $fileHashInput = $_.Hash.ToLower()
        Write-Output "$($numHashesMatchedIndex): $($fileHashInput) was found."
        # AddChecksumResultToHashTable($fileNameInput.ToString(), $fileHashInput) refer to the 4988226 qn link at the function definition
        AddChecksumResultToHashTable $fileNameInput.ToString() $fileHashInput

    } else {
        Write-Warning "!!: Hash for $($_.Path) was not found. "
    }
}
}
# ***** ***** ***** ***** *****



Write-Output "`nEnd compute hash and comparing of files. `n***** Ending Ps Script *****"

# ***** ***** ***** ***** *****
# the following links are some of the reading that helped in creation of the above Ps script
# ~/ means it follows the partial link that may be a few lines above
# ***** ***** ***** ***** *****

# ***** ***** ***** ***** *****
# 
# ***** ***** ***** ***** *****

# stackoverflow: 5592531/how-to-pass-an-argument-to-a-powershell-script
# at start of script, param([Int32]$yourParam=30), then use that $yourParam in the entirety of the Ps script

# stackoverflow: 7342597/how-do-you-comment-out-code-in-powershell
# ans by JPBlanc using <# #> and also .SYNOPSIS & other keywords

# stackoverflow: 31663644/how-do-i-find-the-position-of-substring-in-powershell-after-position-x
# LastIndexOf or IndexOf

# stackoverflow: 28768285/check-text-file-content-in-powershell
# get content of file

#stackoverflow: 22846596/what-does-percent-do-in-powershell
# get alias for % by Get-Alias -Definition ForEach-Object
# %{} means foreach 

# Get-Content documentation on docs.microsoft.com for Powershell 7
# use -TotalCount 5 to limit number of lines read

# https://ss64.com/ps/trim.html
# Trim(), TrimStart(), TrimEnd()

# ***** ***** ***** ***** *****
# the following links helped in creation of the Ps script to copy C codes and NodeJs codes to backup locations
# ***** ***** ***** ***** *****

# docs.microsoft.com/en-us/powershell/scripting
# ~/getting-started/getting-started-with-windows-powershell?view=powershell-7
# resource to learn some concepts of powershell & brief starting intro to some methods/examples
# ~/learn/learning-powershell-names?view=powershell-v7
# note: to get Ps to print list of cmdlet with specific verb
# e.g. Get-Command -Verb Get
# ~/learn/using-variables-to-store-objects?view=powershell-7
# $loc | Get-Member -MemberType Property
# Get-Command -Noun Variable | Format-Table -Property Name,Definition -Autosize -Wrap

# docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management
# ~/copy-item?view=powershell-7
# ~/test-path?view=powershell-5.1 OR powershell-7
# if Ps vers is <= 6.1.2, IsValid & PathType used tgt ignores PathType switch

# stackoverflow: 15113413/how-do-i-concatenate-strings-and-variables-in-powershell
# can use Write-Host "$($varA) - $($varB)"

# stackoverflow: 16906170/create-directory-if-it-does-not-exist
# ans by 'Andy Arismendi' & 'Guest' Test-Path examples

# stackoverflow: 13687550/create-a-function-with-optional-call-variables
# base idea how to create functions in Ps

# stackoverflow: 731752/exclude-list-in-powershell-copy-item-does-not-appear-to-be-working

# stackoverflow: 49492226/powershell-copy-all-folder-structure-and-exclude-one-or-more-folders

# powershell-guru.com/dont-do-that-3-multiple-write-host-to-add-new-lines/
# how to create new lines using ` escape character

# windowscentral.com/how-create-and-run-your-first-powershell-script-file-windows-10
# how to create Ps scripts, run it as well as desc 4 execution policies

# 210320 links
# techblog.dorogin.com/powershell-how-to-recursively-copy-a-folder-structure-excluding-some-child-folders-and-files-a1de7e70f1b

# docs.microsoft.com/en-us/
# ~/dotnet/standard/base-types/regular-expression-language-quick-reference
# more complete ref compared to next line link
# ~/powershell-module/microsoft.powershell/core/about/about_regular_expressions?view=powershell-7