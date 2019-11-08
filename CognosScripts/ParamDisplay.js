define( function() {
	"use strict";
	
	/*
		Module Type:	Custom Control Module
		Purpose:		Reads from sessionStorage and, for each parameter, displays the prompt name and selected values.
	*/
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	function ParamDisplay() {};
	
	ParamDisplay.prototype.initialize = function(oControlHost, fnDoneInitializing) {
		log("ParamDisplay", "CustomControlModule.initialize" );
		
		this.Params = window.Application.GetParameterValues();
		
		fnDoneInitializing();
	};
	
	ParamDisplay.prototype.destroy = function(oControlHost) {
		//log("ParamDisplay", "CustomControlModule.destroy" );
	};
	
	ParamDisplay.prototype.draw = function(oControlHost) {
		log("ParamDisplay", "CustomControlModule.draw" );
		
		var tbl = document.createElement("table");
		this.Params.forEach(function(e) {
			var tr = document.createElement("tr");
			var paramName = document.createElement("td");
			paramName.appendChild(document.createTextNode(e.name));
			paramName.style.verticalAlign = "top";
			tr.appendChild(paramName);
			var paramValue = document.createElement("td");
			paramValue.style.verticalAlign = "top";
			var ParamValue = "";
			//var paramDiv = document.createElement("div");
			var bRange = false;
			e.value.forEach(function(v) {
				if (v.type.indexOf("Range") != -1) {
					bRange = true;
					var paramDiv = document.createElement("div");
					ParamValue = ((typeof v.start == "undefined") ? "" : v.start.display) + " to " + ((typeof v.end == "undefined") ? "" : v.end.display);
					paramDiv.appendChild(document.createTextNode(ParamValue));
					paramValue.appendChild(paramDiv);
				}
				else {
					ParamValue += ", " + ((typeof v.display == "undefined") ? "" : v.display);
				}
			});
			if (!bRange) paramValue.appendChild(document.createTextNode(ParamValue.substring(2)));
			tr.appendChild(paramValue);
			tbl.appendChild(tr);
		});
		oControlHost.container.appendChild(tbl);
	};
	
	ParamDisplay.prototype.show = function(oControlHost) {
		//log("ParamDisplay", "CustomControlModule.show" );
	};
	
	ParamDisplay.prototype.hide = function(oControlHost) {
		//log("ParamDisplay", "CustomControlModule.hide" );
	};
	
	ParamDisplay.prototype.isInValidState = function(oControlHost) {
		//log("ParamDisplay", "CustomControlModule.isInValidState" );
	};
	
	ParamDisplay.prototype.getParameters = function(oControlHost) {
		//log("ParamDisplay", "CustomControlModule.getParameters" );
	};
	
	ParamDisplay.prototype.setData = function(oControlHost, oDataStore) {
		//log("ParamDisplay", "CustomControlModule.setData" );
	};
	
	return ParamDisplay;
});