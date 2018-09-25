define (["/CognosScripts/ObjectMethods.js"], function () {
	
	
	//var log = function (message) {
	//	console.log("    Order Of Methods : " + message);
	//}
	
	function PageModule() {
	};
	
	PageModule.prototype.load = function( oPage ) {
		if (!oPage.ScriptLog) {
			var p = document.createElement("pre");
			oPage.ScriptLog = oPage.getControlByName("ScriptLog").element.appendChild(p);
		}
		this.log = function (message) {
			s = "    Order Of Methods : page module " + message + "\r\n";
			oPage.ScriptLog.textContent += s;
			//oPage.getControlByName("ScriptLog").element.childNode.textContent += "    Order Of Methods : page module " + message + "\r\n";
			console.log(s);
		};
		this.log("load");
	};
	
	PageModule.prototype.show = function( oPage ) {
		this.log("show");
	};
	
	PageModule.prototype.hide = function( oPage ) {
		this.log("hide");
	};
	
	PageModule.prototype.destroy = function( oPage ) {
		this.log("destroy");
	};

return PageModule;
});