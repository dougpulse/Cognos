/*
	author:		doug pulse
	created:	2016-05-13
	license:	public domain
	
	input:		object	the results of running xml2json on databaseserver.IBMCognosAudit.COGIPF_PARAMETER.COGIPF_PARAMETER_VALUE_BLOB
	
	output:		object	something smaller -- only what we actually need from the original data
	
	purpose:	When a report is run in IBM Cognos BI (10.2.1, 10.2.2, 11.0.2), 
				the system optionally* stores parameter values in the 
				COGIPF_PARAMETER_VALUE_BLOB column of the COGIPF_PARAMETER 
				table in the Cognos Audit database (commonly named IBMCognosAudit). 
					databaseserver.IBMCognosAudit.COGIPF_PARAMETER.COGIPF_PARAMETER_VALUE_BLOB
				All of the report parameters are included in the string, 
				regardless of whether or not they are used.  It is stored as 
				ntext, but the data is xml.  After converting the xml to json 
				(see xml2json.js), the string can be used as input for this function.
				cleanParams() strips the parameter data down to only what was 
				actually used when the report was run.  It also dramatically 
				simplifies the object, removing all of the Cognos-specific 
				stuff that no Cognos admininstrator would ever find useful.
				
		*	create a custom property in the advanced properties for the 
			Report and Batch Report services:
				RSVP.PARAMETERS.LOG = true
*/

function cleanParams (params) {
	var p = params.parameterValues.item;
	var o = new Object();
	
	//	iterate through each of the parameters recorded in the data
	if (p.length > 1) {
		for (var i = 0; i < p.length; i++) {
			console.log("    " + i);
			//	look for parameters that are actually used
			if (p[i]["bus:value"]["@SOAP-ENC:arrayType"] != "bus:parmValueItem[0]") {
				//	the value should not have a 0
				//	something like "bus:parmValueItem[1]"
				//	the number defines the length of the array of values
				var name = p[i]["bus:name"]["#text"];
				var vals = p[i]["bus:value"]["item"];
				o[name] = [];
				var n = p[i]["bus:value"]["@SOAP-ENC:arrayType"].replace(/bus:parmValueItem\[/gi, "").replace(/]/gi, "");
				console.log("        " + n);
				
				if (n == 1) {
					if (vals["@xsi:type"] == "bus:boundRangeParmValueItem") {
						//	in_range prompts are special:
						o[name].push({start: {display: vals["bus:start"]["bus:display"]["#text"], use: vals["bus:start"]["bus:use"]["#text"]}, "end": {display: vals["bus:end"]["bus:display"]["#text"], use: vals["bus:end"]["bus:use"]["#text"]}});
					}
					else {
						try {
							o[name].push({display: vals["bus:display"]["#text"], use: vals["bus:use"]["#text"]});
						}
						catch (e) {
							console.log(e.message);
							console.log(JSON.stringify(params));
						}
					}
				}
				else {
					for (var j = 0; j < n; j++) {
						console.log("            " + j);
						if (vals[j]["@xsi:type"] == "bus:boundRangeParmValueItem") {
							//	in_range prompts are special:
							o[name].push({start: {display: vals[j]["bus:start"]["bus:display"]["#text"], use: vals[j]["bus:start"]["bus:use"]["#text"]}, end: {display: vals[j]["bus:end"]["bus:display"]["#text"], use: vals[j]["bus:end"]["bus:use"]["#text"]}});
						}
						else {
							try {
								o[name].push({display: vals[j]["bus:display"]["#text"], use: vals[j]["bus:use"]["#text"]});
							}
							catch (e) {
								console.log(e.message);
								console.log(JSON.stringify(params));
							}
						}
					}
				}
			}
		}
	}
	else {
		//	there is only one parameter
		//	look for parameters that are actually used
		if (p["bus:value"]["@SOAP-ENC:arrayType"] != "bus:parmValueItem[0]") {
			//	the value should not have a 0
			//	something like "bus:parmValueItem[1]"
			//	the number defines the length of the array of values
			var name = p["bus:name"]["#text"];
			var vals = p["bus:value"]["item"];
			o[name] = [];
			var n = p["bus:value"]["@SOAP-ENC:arrayType"].replace(/bus:parmValueItem\[/gi, "").replace(/]/gi, "");
			
			if (n == 1) {
				if (vals["@xsi:type"] == "bus:boundRangeParmValueItem") {
					//	in_range prompts are special:
					o[name].push({start: {display: vals["bus:start"]["bus:display"]["#text"], use: vals["bus:start"]["bus:use"]["#text"]}, "end": {display: vals["bus:end"]["bus:display"]["#text"], use: vals["bus:end"]["bus:use"]["#text"]}});
				}
				else {
					o[name].push({display: vals["bus:display"]["#text"], use: vals["bus:use"]["#text"]});
				}
			}
			else {
				for (var j = 0; j < n; j++) {
					if (vals[j]["@xsi:type"] == "bus:boundRangeParmValueItem") {
						//	in_range prompts are special:
						o[name].push({start: {display: vals[j]["bus:start"]["bus:display"]["#text"], use: vals[j]["bus:start"]["bus:use"]["#text"]}, end: {display: vals[j]["bus:end"]["bus:display"]["#text"], use: vals[j]["bus:end"]["bus:use"]["#text"]}});
					}
					else {
						o[name].push({display: vals[j]["bus:display"]["#text"], use: vals[j]["bus:use"]["#text"]});
					}
				}
			}
		}
	}
	
	//	return the cleaned parameter value data
	return o;
}
