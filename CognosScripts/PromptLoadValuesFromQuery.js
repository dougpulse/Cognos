define( function() {
	"use strict";
	
	/*
	Add data sets to the control.
	Add one query item to Categories.
	Name the data set the same as the target prompt.
	Ensure the custom control appears after the prompt in the layout.
	The query output in the data set will appear in the prompt.
	
	Tested with multi-select textbox prompts.
	*/
	
	var log = function (name, label, message) {
		console.log("    ****    " + name + " : " + label + " : " + message);
	};
	
	var convertValues = function (valArray) {
		var a = [];
		valArray.forEach(function (n) {
			a.push({"use": n, "display": n});
		});
		return a;
	};
	
	function loadFromQuery(){};
	
	
	loadFromQuery.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		log(oControlHost.control.name, "initialize", "start");
		
		this.vals = [];
		
		fnDoneInitializing();
		log(oControlHost.control.name, "initialize", "complete");
	};
	
	loadFromQuery.prototype.draw = function( oControlHost ) {
		log(oControlHost.control.name, "draw", "start");
		
		var o = oControlHost.configuration;
		var oPage = oControlHost.page;
		for (var e in this.vals) {
			var oPrompt = oPage.getControlByName(this.vals[e].name);
			oPrompt.setValues(convertValues(this.vals[e].values));
		}
		
		log(oControlHost.control.name, "draw", "complete");
	};

	loadFromQuery.prototype.setData = function( oControlHost, oDataStore ) {
		log(oControlHost.control.name, "setData:" + oDataStore.name, "start");
		
		this.m_oDataStore = oDataStore;
		this.m_aData = [];
		var iRowCount = oDataStore.rowCount;
		for ( var iRow = 0; iRow < iRowCount; iRow++ ) {
			this.m_aData.push(oDataStore.getCellValue( iRow, 0 ));
		}
		
		if (this.m_aData.length) {
			this.m_aData.sort();
			
			var thisPrompt = {}
			thisPrompt.name = oDataStore.name;
			thisPrompt.values = this.m_aData.slice();
			this.vals.push(thisPrompt);
		}
		
		log(oControlHost.control.name, "setData:" + oDataStore.name, "complete");
	};
	
	return loadFromQuery;
});


