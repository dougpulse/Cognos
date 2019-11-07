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
		
		/*
		//	this part is needed if using 11.1.4
		var ReportFrame = null;
		var ReportFrameID = window.__glassAppController.getCurrentContentView().id;

		for (var i = 0; i < window.frames.length; ++i) {
			if (window.frames[i].Application.GlassView && window.frames[i].Application.GlassView.id == ReportFrameID) {
				ReportFrame = window.frames[i];
				break;
			}
		}
		this.Params = ReportFrame.Application.GetParameterValues();
		*/
		
		//	11.0.13 is simpler
		this.Params = window.Application.GetParameterValues();
		
		fnDoneInitializing();
	};
	
	ParamDisplay.prototype.destroy = function(oControlHost) {
		log("ParamDisplay", "CustomControlModule.destroy" );
	};
	
	ParamDisplay.prototype.draw = function(oControlHost) {
		log("ParamDisplay", "CustomControlModule.draw" );
		
		this.Params.forEach(function(e) {
			var ne = document.createElement("div");
			var ParamValue = "";
			e.value.forEach(function(v) {
				if (v.type.indexOf("Range") != -1) {
					ParamValue += ", start: " + ((typeof v.start == "undefined") ? "" : v.start.display) + ", end: " + ((typeof v.end == "undefined") ? "" : v.end.display);
				}
				else {
					ParamValue += ", " + ((typeof v.display == "undefined") ? "" : v.display);
				}
			});
			ParamValue = ParamValue.substring(2);
			var nc = document.createTextNode(e.name + ":  " + ParamValue);
			ne.appendChild(nc);
			oControlHost.container.appendChild(ne);
		});
	};
	
	ParamDisplay.prototype.show = function(oControlHost) {
		log("ParamDisplay", "CustomControlModule.show" );
	};
	
	ParamDisplay.prototype.hide = function(oControlHost) {
		log("ParamDisplay", "CustomControlModule.hide" );
	};
	
	ParamDisplay.prototype.isInValidState = function(oControlHost) {
		log("ParamDisplay", "CustomControlModule.isInValidState" );
	};
	
	ParamDisplay.prototype.getParameters = function(oControlHost) {
		log("ParamDisplay", "CustomControlModule.getParameters" );
	};
	
	ParamDisplay.prototype.setData = function(oControlHost, oDataStore) {
		log("ParamDisplay", "CustomControlModule.setData" );
	};
	
	return ParamDisplay;
});