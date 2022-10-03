Param([Parameter(Mandatory=$true, ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$txtFileUnboughtBundle, [Parameter(Mandatory=$true, ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$bundleToCheckAgainst)

$bundleItemsTxtFile = Get-Content $txtFileUnboughtBundle

$booksContainedInNewBundle = @{}

$bundleItemsTxtFile | %{
    if($_.ToString() -Like "*: *") {
        $startIndex = $_.ToString().IndexOf(": ") + 2
        $endIndex = $_.ToString().LastIndexOf("(")
        if ($endIndex -eq -1) {
            # Write-Output $_.ToString().Substring($startIndex).Trim()
            $booksContainedInNewBundle.Add($_.ToString().Substring($startIndex).Trim(), "")
        } elseif ($endIndex -gt -1) {
            # Write-Output $_.ToString().SubString($startIndex, $endIndex - $startIndex).Trim()
            $booksContainedInNewBundle.Add($_.ToString().SubString($startIndex, $endIndex - $startIndex).Trim(), "")
        }
    }
}

$bundleHashAndTitleEntries = Get-Content (Get-ChildItem -Path $bundleToCheckAgainst -Recurse -Force -Depth 1 -Filter "md5Sums*_newFmt.txt").FullName
$separatorThatMightBePresentInHashTitleEntries = "********************************"
$countDuplicatesFoundFromNewBundleToComparedBundle = 0

$booksContainedInNewBundle.keys |
%{
    foreach ($lineText in $bundleHashAndTitleEntries) {
        if ($lineText -contains $separatorThatMightBePresentInHashTitleEntries) {
            Write-Output "skipping the 32 * separator in the file..."
        }
        elseif ($lineText.Length -ne 0) {
            <# 301220: try and avoid perform exact match, as the webpg inconsistent for append Edition 
                on the display page vs the download page
            #>

            # [int] $quarterLengthOfString = $lineText.Length / 4;
            [int] $quarterLengthOfString = $($lineText.LastIndexOf("/") - 33) / 4;

            $newBundleItemWithoutEditionAtEnd = ""
            if ($_ -Match "Edition") {
                $lastCommaForBookTitleWithEditionWordInIt = $_.LastIndexOf(",")
                $lastDashForBookTitleWithEditionWordInIt = $_.LastIndexOf("-")
                if ($lastCommaForBookTitleWithEditionWordInIt -gt -1) {
                    $newBundleItemWithoutEditionAtEnd = $_.Substring(0, $lastCommaForBookTitleWithEditionWordInIt)
                } elseif ($lastDashForBookTitleWithEditionWordInIt -gt -1) {
                    $newBundleItemWithoutEditionAtEnd = $_.Substring(0, $lastDashForBookTitleWithEditionWordInIt)
                } else {
                    Write-Warning "Book title after removing self-created parenthesis for Edition still has Edition word, but separator near end is not , or -..."
                    Write-Warning "Affected book is $($_)"
                    break
                }
                
                # Write-Output "`'$($newBundleItemWithoutEditionAtEnd)`'"
            } else {
                $newBundleItemWithoutEditionAtEnd = $_
            }
            if ($lineText.Substring(33, $lineText.LastIndexOf("/") - 33) -Match [Regex]::Escape($newBundleItemWithoutEditionAtEnd)) { # Jan 2022: see note 1

                Write-Warning "`'$($_.ToString())`' of new bundle already exists in this bundle you are comparing with."
                $countDuplicatesFoundFromNewBundleToComparedBundle++
                break # once an item in the new bundle is found within existing bundles, break the foreach loop, else multiple printing of duplicate statement due to .pdf, .epub entries in file of hash
            }


        }
    }
}
Write-Output "Number of duplicates found: $($countDuplicatesFoundFromNewBundleToComparedBundle)"

# ***** ***** ***** ***** *****
# the following links are some of the reading that helped in creation of the above Ps script
# ***** ***** ***** ***** *****
# https://stackoverflow.com/questions/18877580/powershell-and-the-contains-operator
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7
# https://docs.microsoft.com/en-us/dotnet/api/system.string.substring?view=netcore-3.1
# https://docs.microsoft.com/en-us/dotnet/api/system.string.lastindexof?view=netcore-3.1#System_String_LastIndexOf_System_Char_
# https://stackoverflow.com/questions/29126555/set-data-structure-in-powershell
# https://stackoverflow.com/questions/51514897/compare-two-hashtable-in-powershell

# ***** ***** ***** ***** *****
# notes
# ***** ***** ***** ***** *****
# 1. Jan 2022: ans by Keith Miller, Match uses regular expression vs Write-Output which takes literal or expansion string
# use [Regex]::Escape($yourStringWhichIsPassedToMatchOperator) to get string w/ all special characters escaped.
# string which caused issue contained 'C++'
# e.g. err message
<# 
parsing "Data Structures and Algorithms in C++" - Nested quantifier +.
At C:\MANAGED\a_transferRef\520s\Dec21\291121\toBU\PsScripts\520s\hashAndOp\newBundleChkAgstExistBundleItemDupl_301220.ps1:95 char:83
+ ... LastIndexOf("/") - 33) -Match $($newBundleItemWithoutEditionAtEnd)) {
+                                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (:) [], ArgumentException
    + FullyQualifiedErrorId : System.ArgumentException
#>
# relevant link: https://superuser.com/questions/1685323/how-to-escape-a-character-in-write-output-with-powershell