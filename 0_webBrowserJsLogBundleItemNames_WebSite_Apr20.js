/* 
***** ***** ***** ***** *****
260521 start: updated automate data get due to changed UI on bundles page
190521: 
// https://stackoverflow.com/questions/22754315/for-loop-for-htmlcollection-elements
050621: remove multiple words from string
https://stackoverflow.com/questions/49655135/javascript-regex-remove-multiple-words-from-string
***** ***** ***** ***** *****
 */
let finalText = '';

// 050621: changed UI when view bundle, needed lines to include tier seperator
let totalNumItemGainedAtTierLvl = document.getElementsByClassName('js-tier-filter');

let wordsToRemove = ['Entire', 'Item', 'Bundle'];
let wordsToRemoveJoinedForUseInRegex = wordsToRemove.join("|");
let tierBundle = [];

[...totalNumItemGainedAtTierLvl].map(jsFilterText => {
    let rawTextCannotUseAsNumbersYet = jsFilterText.innerText;
    let regexedText = rawTextCannotUseAsNumbersYet.replace(new RegExp(wordsToRemoveJoinedForUseInRegex, 'gi'), '');
    console.log(regexedText.trim());
    tierBundle.push(regexedText / 1);
});
let tier2Position = tierBundle[0] - tierBundle[1];
let tier3Position = tierBundle[0] - tierBundle[2];

let interestedItemTierList = document.getElementsByClassName('tier-item-view');

let bundleIdxCounter = 0;

[...interestedItemTierList].map(tierListHtmlElem => {

    // 050621: changed UI when view bundle, needed lines to include tier seperator(assuming bundle only split into 3 tier)
    if (bundleIdxCounter == 0) {
        finalText += "Tier 1\n";
    } else if (bundleIdxCounter == (tier2Position)) {
        finalText += "Tier 2\n";
    } else if (bundleIdxCounter == (tier3Position)) {
        finalText += "Tier 3\n";
    }

    let itemTitle = tierListHtmlElem.getElementsByClassName('item-title')[0].innerText;

    finalText += `${bundleIdxCounter}: ${itemTitle}`;

    let editionOrVideoOrAdditionalInfo = tierListHtmlElem.getElementsByClassName('item-flavor-text')[0];
    // if ( editionOrVideoOrAdditionalInfo != undefined ) {
    if (editionOrVideoOrAdditionalInfo.innerText.length != 0) {
        finalText += ` (${editionOrVideoOrAdditionalInfo.innerText})`;
    }


    finalText += '\n';
    bundleIdxCounter++;
}
);
console.log(finalText);
