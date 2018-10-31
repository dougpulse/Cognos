define (["/CognosScripts/json.js", "/CognosScripts/xml2json.js", "/CognosScripts/cleanParams.js"], function () {
	/*
		author:		doug pulse
		created:	2016-05-13
		license:	public domain
		
		input:		object	parameter name/value pairs returned by cleanParams
		
		output:		string	something more useful for reporting
		
		purpose:	Convert a list of parameter values stored as a javascript 
					object into a string.
		
		usage:		After converting the parameter data from the original XML in 
					databaseserver.IBMCognosAudit.COGIPF_PARAMETER.COGIPF_PARAMETER_VALUE_BLOB
					to a JSON string, the resulting JSON can be parsed (JSON.parse) 
					into an object and used as input to these functions.
					
					This function expects a single value from a single audit record.  The 
					custom control for this script should be in a list column body.  The 
					master-detail relationships property of the data set should be set to 
					join to the main data set on COGIPF_SUBREQUESTID so that each custom 
					control receives only one value from the COGIPF_PARAMETER_VALUE_BLOB column.
	*/
	
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	ParameterDisplayValues = function (o) {
		var sOut = "";
		var vals = [];
		for (var a in o) {
			//alert(a);
			sOut += a;
			vals = [];
			if (o[a][0].start) {
				sOut += " in range {";
				for (var i = 0; i < o[a].length; i++) {
					vals.push(o[a][i].start.display + " to " + o[a][i].end.display);
				}
			}
			else {
				sOut += " = {";
				for (var i = 0; i < o[a].length; i++) {
					vals.push(o[a][i].display);
				}
			}
			sOut += vals.toString() + "}\n";
		}
		return sOut;
	}
	
	//ParameterValues = function (o) {
	//	var sOut = "";
	//	var vals = [];
	//	for (var a in o) {
	//		//alert(a);
	//		sOut += a;
	//		vals = [];
	//		if (o[a][0].start) {
	//			sOut += " in range {";
	//			for (var i = 0; i < o[a].length; i++) {
	//				vals.push(o[a][i].start.use + " to " + o[a][i].end.use);
	//			}
	//		}
	//		else {
	//			sOut += " = {";
	//			for (var i = 0; i < o[a].length; i++) {
	//				vals.push(o[a][i].use);
	//			}
	//		}
	//		sOut += vals.toString() + "}\n";
	//	}
	//	return sOut;
	//}

	
	
	
	function ParameterToText() {
	};
	
	ParameterToText.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		log("ParameterToText", "Control.initialize" );
		fnDoneInitializing();
	};
	
	ParameterToText.prototype.draw = function( oControlHost ) {
		log("ParameterToText", "Control.draw" );
		var o = oControlHost.configuration;
		this.colName = ( o && o.colName ) ? o.colName : "Parameter XML";
		
		//log("Parameter XML", this.xml);
		var j = xml2json(this.xml);  //  returns a string
		var o = JSON.parse(j);  //  returns an object
		var c = cleanParams(o); //  returns
		var s = ParameterDisplayValues(c);
		//return s.replace(/\n/gi, "&lt;br /&gt;");
		
		var f = document.createElement("span");
		f.innerHTML = s.replace(/\n/gi, "<br />");
		
		oControlHost.container.appendChild(f);
	};

	ParameterToText.prototype.setData = function( oControlHost, oDataStore ) {
		log("ParameterToText", "Control.setData" );
		log("ParameterToText", "Control.draw" );
		var o = oControlHost.configuration;
		this.colName = ( o && o.colName ) ? o.colName : "Parameter XML";
		var colNum = oDataStore.getColumnIndex(this.colName);
		console.log("        subrequest id = " + oDataStore.getCellValue(0, oDataStore.getColumnIndex("Subrequest ID")));
		this.xml = oDataStore.getCellValue(0, colNum);
	};
	
	return ParameterToText;
});
