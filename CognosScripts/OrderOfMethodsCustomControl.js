define( function() {
	"use strict";
	
	//var log = function (message) {
	//	console.log("    Order Of Methods :     " + message);
	//}
	
	function AdvancedControl() {
	};
	
	AdvancedControl.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		this.config = oControlHost.configuration;
		this.log = function (message) {
			if (!oControlHost.page.ScriptLog) {
				var p = document.createElement("pre");
				oControlHost.page.ScriptLog = oControlHost.page.getControlByName("ScriptLog").element.appendChild(p);
			}
			s = "    Order Of Methods :     custom control " + this.config.ControlNum + " " + message + "\r\n";
			oControlHost.page.ScriptLog.textContent += s;
			//oControlHost.page.getControlByName("ScriptLog").element.childNode.textContent += "    Order Of Methods :     custom control " + this.config.ControlNum + " " + message + "\r\n";
			console.log(s);
		};
		this.log("initialize");
		fnDoneInitializing();
	};
	
	AdvancedControl.prototype.destroy = function( oControlHost ) {
		this.log("destroy");
	};
	
	AdvancedControl.prototype.draw = function( oControlHost ) {
		this.log("draw");
	};
	
	AdvancedControl.prototype.show = function( oControlHost ) {
		this.log("show");
	};
	
	AdvancedControl.prototype.hide = function( oControlHost ) {
		this.log("hide");
	};
	
	AdvancedControl.prototype.isInValidState = function( oControlHost ) {
		this.log("isInValidState");
		return true;
	};
	
	AdvancedControl.prototype.getParameters = function( oControlHost ) {
		this.log("getParameters");
	};
	
	AdvancedControl.prototype.setData = function( oControlHost, oDataStore ) {
		this.log("setData");
	};
	
	return AdvancedControl;
});