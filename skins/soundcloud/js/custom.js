//
// Version 1.0 - 20090708
//
// If the name of the Javascript file is 'custom.js' it will be included automatically.
//
// Calls to the following Javascript functions should be placed in 'cfooter.txt' to make
// sure the entire page is loaded.

// Show the maximum amount additional credit card costs (only OPP).
// DEPRECATED! This functionality now forms part of the core code.

// function showCardCosts() {
//	var maxCostItem = 0;
//	var maxCostAmount = 0;
	
//	for(var i = 0; i < card_extras.length; ++i) {
//		if (card_extras[i] > maxCostAmount) {
//			maxCostItem = i;
//			maxCostAmount = card_extras[i];
//		}
//	}
	
//	document.getElementById('pmmextracosts-card').innerHTML = card_extras[maxCostItem];
//}

// Alter the destination of the back button (only OPP).
function alterPreviousButtonURL() {
	document.getElementById('mainBack').onclick=function () {this.blur(); document.location = 'http://example.com/index.html'; return false;}
}

// Collapse the order data sent and make it expandable.
var collapseOrderData;

function collapseOrder() {
	collapseOrderData = new animatedcollapse("orderDataContents", 1000, false, false, config["pmmanimation"]==1?false:true);
}

