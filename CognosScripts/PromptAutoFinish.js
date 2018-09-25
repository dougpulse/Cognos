define( function() {
	"use strict";
	
	function AutoFinish() {
	};
	
	AutoFinish.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		if (!oControlHost.page.AutoFinish) {
			console.log("    Defining AutoFinish");
			oControlHost.page.AutoFinish = function () {oControlHost.next()};
		}
		fnDoneInitializing();
	};
	
	AutoFinish.prototype.draw = function( oControlHost ) {
	};
	
	return AutoFinish;
});