define( function() {
	"use strict";
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	};
	
	function AutoFinish() {
	};
	
	AutoFinish.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		log("AutoFinish", "Control.initialize" );
		if (!oControlHost.page.AutoFinish) {
			console.log("    Defining AutoFinish");
			oControlHost.page.AutoFinish = function () {
				oControlHost.next()
			};
		}
		fnDoneInitializing();
	};
	
	AutoFinish.prototype.draw = function( oControlHost ) {
		log("AutoFinish", "Control.draw" );
	};
	
	return AutoFinish;
});