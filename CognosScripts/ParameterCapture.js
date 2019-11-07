define(function () {
	"use strict";
	
	/*
		Module Type:	Page Module
		Purpose:		Captures parameter name, prompt name, and selected 
						parameter values.
						Stores data in sessionStorage for retrieval by the 
						next prompt page using this module or a custom control 
						using the ParameterDisplay Custom Control Module.
		Requirements:	The first prompt page must have a layout calculation 
						named "ReportName" defined as ReportName()
		Future:			This functionality should probably be incorporated 
						into Prompts.js.
	*/
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	function PageModule() {
	};
	
	PageModule.prototype.load = function(oPage) {
		log("page", "PageModule.load" );
		
		var crObject = oPage.getControlByName("ReportName");
		//this.CurrentReport = "";
		this.CurrentReport = sessionStorage.getItem("CurrentReport");
		if (crObject) {
			this.CurrentReport = crObject.text;
			sessionStorage.setItem("CurrentReport", this.CurrentReport);
		}
		
		//var apc = oPage.getAllPromptControls();
		//
		//apc.forEach(function (n) {
		//	log("	Prompts:  ", n.name);
		//});
	};
	
	PageModule.prototype.show = function(oPage) {
		log("page", "PageModule.show" );
	};
	
	PageModule.prototype.hide = function(oPage) {
		log("page", "PageModule.hide" );
	};
	
	PageModule.prototype.destroy = function(oPage) {
		log("page", "PageModule.destroy" );
		
		if (this.CurrentReport) {
			if (!sessionStorage.getItem("Parameters" + this.CurrentReport)) {
				sessionStorage.setItem("Parameters" + this.CurrentReport, JSON.stringify({}));
			}
			
			var prompts = oPage.getAllPromptControls();
			prompts.forEach(function (e) {
				var p = JSON.parse(sessionStorage.getItem("Parameters" + this.CurrentReport));
				var v1 = e.getValues();
				var v2 = JSON.stringify(v1);
				var v3 = e.name;
				var v4 = [v3, v2];
				p[e.parameter] = JSON.stringify(v4);
				//p[e.parameter] = JSON.stringify([e.name, JSON.stringify(e.getValues())]);
				sessionStorage.setItem("Parameters" + this.CurrentReport, JSON.stringify(p));
			}, this);
		}
	};
	
	return PageModule;
});