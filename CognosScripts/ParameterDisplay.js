define( function() {
	"use strict";
	
	/*
		Module Type:	Custom Control Module
		Purpose:		Reads from sessionStorage and, for each parameter, displays the prompt name and selected values.
	*/
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	function ParameterDisplay() {};
	
	ParameterDisplay.prototype.initialize = function(oControlHost, fnDoneInitializing) {
		log("ParameterDisplay", "CustomControlModule.initialize" );
		this.CurrentReport = sessionStorage.getItem("CurrentReport");
		fnDoneInitializing();
	};
	
	ParameterDisplay.prototype.destroy = function(oControlHost) {
		log("ParameterDisplay", "CustomControlModule.destroy" );
	};
	
	ParameterDisplay.prototype.draw = function(oControlHost) {
		log("ParameterDisplay", "CustomControlModule.draw" );
		
		if (this.CurrentReport) {	//	if there is no object named ReportName, don't try to display parameters
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
		}
		
		//oControlHost.container.innerHTML = JSON.stringify(apn);
	};
	
	ParameterDisplay.prototype.show = function(oControlHost) {
		log("ParameterDisplay", "CustomControlModule.show" );
	};
	
	ParameterDisplay.prototype.hide = function(oControlHost) {
		log("ParameterDisplay", "CustomControlModule.hide" );
	};
	
	ParameterDisplay.prototype.isInValidState = function(oControlHost) {
		log("ParameterDisplay", "CustomControlModule.isInValidState" );
	};
	
	ParameterDisplay.prototype.getParameters = function(oControlHost) {
		log("ParameterDisplay", "CustomControlModule.getParameters" );
	};
	
	ParameterDisplay.prototype.setData = function(oControlHost, oDataStore) {
		log("ParameterDisplay", "CustomControlModule.setData" );
	};
	
	return ParameterDisplay;
});