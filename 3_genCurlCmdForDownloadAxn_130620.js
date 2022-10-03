/* 
***** ***** ***** ***** *****
130620 start: modified version as my bundle file structure is different
***** ***** ***** ***** *****
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