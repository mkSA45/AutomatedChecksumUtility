/* 
***** ***** ***** ***** *****
130720 start: changes to script to ensure recording of the dldate when the dlmd5 checksum was calculated, and new format of recording hash
***** ***** ***** ***** *****
 */
let bookListHtmlElem = document.getElementsByClassName('js-download-rows')[0];
let finalInterestedText3 = '';

/* 
note: as of around May-Jun 2022, download pages no longer list the md5 button which reveals the md5 hash of the pdf, epub, mobi or zip file
let allHiddenMd5BookList = bookListHtmlElem.getElementsByClassName('dlmd5');

for (var i = 0; i < allHiddenMd5BookList.length; i++) {
    allHiddenMd5BookList[i].click();
}
 */
if (document.getElementsByClassName('dlmd5').length == 0) {
    finalInterestedText3 += 'NOHASH ON BUNDLE PAGE\n'; // 1st line text required for one of the scenarios in 4_chkHashOf_ebooks_Feb21.ps1
    // console.log("NOHASH");
}

let rowsOfBooks = bookListHtmlElem.children;

// !!! notes: currTitle thru getElementsByClassName without the [0] is a HTMLCollection of <title> tags 
function cr8InterestedText050320_v2(htmlElemHoldingBookRecords) {

    let returnedText = '';

    for (var i = 0; i < htmlElemHoldingBookRecords.length; i++) {
        let currTitle = htmlElemHoldingBookRecords[i].getElementsByClassName('title')[0];
        
        let allDownloadItemPerRow = htmlElemHoldingBookRecords[i].querySelectorAll('.downloads .download');

        for (var j = 0; j < allDownloadItemPerRow.length; j++) {
            
            /* note: as of around May-Jun 2022, download pages no longer list the md5 button which reveals the md5 hash of the pdf, epub, mobi or zip file
            */
            // static 32 character string, since powershell to check unbought bundle against existing bundle still relies on getting book title name after 33rd character
            // let hashCurrItem = allDownloadItemPerRow[j].querySelector('.dlmd5');
            // returnedText = returnedText.concat(hashCurrItem.innerText);
            // returnedText = returnedText.concat('abcdefghijklmnopqrstuvwxyzabcdef'); 

            /* 
            let dlDateCurrItem = allDownloadItemPerRow[j].querySelector('.dldate');
            if (dlDateCurrItem != undefined || dlDateCurrItem != null) {
                returnedText = returnedText.concat(` (${dlDateCurrItem.innerText})`);
            }
            */

            // Nov 2022; changes to accomodate bundle page no longer having the MD5 hash. 
            // returnedText = returnedText.concat(` ${currTitle.innerText}/`);
            returnedText = returnedText.concat(`${currTitle.innerText}/`);


            let downloadLink = allDownloadItemPerRow[j].querySelector('.flexbtn a');
            
            const filename = /\.com\/([^?]+)/.exec(downloadLink.href)[1];
            returnedText = returnedText.concat(filename);
            returnedText = returnedText.concat('\n');

        }
        returnedText = returnedText.concat('\n');
    }
    return returnedText;
}

// let finalInterestedText3 = cr8InterestedText050320_v2(rowsOfBooks);
finalInterestedText3 += cr8InterestedText050320_v2(rowsOfBooks);
console.log(finalInterestedText3);
