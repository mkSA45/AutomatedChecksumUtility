/* 
***** ***** ***** ***** *****
130620 start: modified version as my bundle file structure is different
***** ***** ***** ***** *****
*/

/**
 * 
 * Notes:
 * 1. when using web browser, 'Bulk Download' on the bundle page seems to initiate download of all files with the specified file type(e.g. pdf, epub, mobi).
 * Not helpful if a lot of the files are very large, then all files download at equally slow pace. Thus, this script was created to perform download by powershell.
 * Requires to view the bundle page by web browser to generate the Powershell lines for downloading.
 * 2. Possible improvement(to verify): 
 * Regarding Powershell's Invoke-WebRequest progress bar in Powershell which slows download considerably compared to using web browser(wget is an alias for Invoke-WebRequest)
 * answers by TinyTheBrontosaurus or LloydBanks(https://stackoverflow.com/questions/28682642/powershell-why-is-using-invoke-webrequest-much-slower-than-a-browser-download) 
 */

function gatherInfo() {
    const data = [];

    document.querySelectorAll('.row').forEach(row => {
        const bookTitle = row.dataset.humanName;
        [...row.querySelectorAll('.downloads .download')].forEach(dl => {
            const downloadLink = dl.querySelector('.flexbtn a').href;
            const filename = /\.com\/([^?]+)/.exec(downloadLink)[1];
            
            data.push({
                
                // "bookTitle": bookTitle,
                "filename": filename,
                "downloadLink": downloadLink
                
            });
        });
    });
    return data;
}
function downloadBookBundle() {
    const commands = []
    
    const info = gatherInfo();
    for (var i in info) {
        
        // bookTitle = info[i]["bookTitle"];
        filename = info[i]["filename"];
        downloadLink = info[i]["downloadLink"];
        
        if (!filename.includes(".mobi") && !filename.includes(".epub")) {
            
            commands.push("If(Test-Path -Path \"" + filename + "\") {Write-Warning \"" + filename + " exists, skipping \"} Else { wget \"" + downloadLink + "\" -Outfile " + filename + "}");
            // commands.push("Start-MpScan -ScanPath \"D:\\download_staging\\TOBMM\\scriptsOutput\\ps\\" + filename + "\" -ScanType CustomScan -CimSession $myCimSession"); // note: for 520s laptop
            commands.push(`Start-MpScan -ScanPath C:\\download_staging\\scriptsOutput\\ps\\${filename} -ScanType CustomScan -CimSession $myCimSession`); // Jan 2022 note; for desktop
        }
        
    };
    console.log(commands.join(' \n'));

}
downloadBookBundle();
/*
***** ***** ***** ***** *****
130620 end: modified version as my bundle file structure is different
***** ***** ***** ***** *****
 */