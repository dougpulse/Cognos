define( function() {
	"use strict";
	
	/*
		Module Type:	Custom Control Module
		Purpose:		Reads from sessionStorage and, for each parameter, displays the prompt name and selected values.
	*/
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	function test2() {};
	
	test2.prototype.initialize = function(oControlHost, fnDoneInitializing) {
		log("test2", "CustomControlModule.initialize" );
		this.CurrentReport = sessionStorage.getItem("CurrentReport");
		fnDoneInitializing();
	};
	
	test2.prototype.destroy = function(oControlHost) {
		log("test2", "CustomControlModule.destroy" );
	};
	
	test2.prototype.draw = function(oControlHost) {
		log("test2", "CustomControlModule.draw" );
		var params = JSON.parse(sessionStorage.getItem("Parameters" + this.CurrentReport));

		Object.keys(params).forEach(function(e) {
			var ss = JSON.parse(params[e]);
			var ne = document.createElement("div");
			var ns = "";
			JSON.parse(ss[1]).forEach(function(f) {
				if (f.start) {
					ns += ", start: " + ((typeof f.start.display == "undefined") ? "" : f.start.display) + ", end: " + ((typeof f.end.display == "undefined") ? "" : f.end.display);
				}
				else {
					ns += ", " + ((typeof f.display == "undefined") ? "" : f.display);
				}
			});
			ns = ns.substring(2);
			var nc = document.createTextNode(ss[0] + ":  " + ns);
			ne.appendChild(nc);
			oControlHost.container.appendChild(ne);
		});
		
		//oControlHost.container.innerHTML = JSON.stringify(apn);
	};
	
	test2.prototype.show = function(oControlHost) {
		log("test2", "CustomControlModule.show" );
	};
	
	test2.prototype.hide = function(oControlHost) {
		log("test2", "CustomControlModule.hide" );
	};
	
	test2.prototype.isInValidState = function(oControlHost) {
		log("test2", "CustomControlModule.isInValidState" );
	};
	
	test2.prototype.getParameters = function(oControlHost) {
		log("test2", "CustomControlModule.getParameters" );
	};
	
	test2.prototype.setData = function(oControlHost, oDataStore) {
		log("test2", "CustomControlModule.setData" );
	};
	
	return test2;
});