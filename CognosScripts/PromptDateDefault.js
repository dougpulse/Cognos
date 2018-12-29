define(["/CognosScripts/ObjectMethods.js"], function() {
	"use strict";
	/*
	Sets a date prompt to the value(s) returned by a query.
	
	The query may return a list of single dates or a list of start and end dates.
	
	Sample Configurations:
	{
		"PromptName": "PromptDate",
		"Date": "Date"
	}
	{
		"PromptName": "PromptDate",
		"StartDate": "StartDate",
		"EndDate": "EndDate"
	}
	
	The data store(s) must contain columns with names that match the values for 
	either Date or StartDate and EndDate.
	The date values must be in the format yyyy-mm-dd.
	*/
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	};
	
	function DateDefault() {};
	
	DateDefault.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		log("DateDefault", "Control.initialize" );
		
		var o = oControlHost.configuration;
		var sPromptName = o && o["PromptName"] ? o["PromptName"] : null;
		var ctrl = oControlHost.page.getControlByName(sPromptName);
		var datastores = oControlHost.control.dataStores ? oControlHost.control.dataStores : null;
		var sDateColumn = o && o["Date"] ? o["Date"] : null;
		var sStartDateColumn = o && o["StartDate"] ? o["StartDate"] : null;
		var sEndDateColumn = o && o["EndDate"] ? o["EndDate"] : null;
		var bValid = true;
		var reDate = /^\d{4}-\d{2}-\d{2}$/;
		var iDateCol, iStartDateCol, iEndDateCol;
		var sDate, sStartDate, sEndDate;
		
		
		//	check configuration
		if (!sPromptName) {
			bValid = false;
			sMsg += "Invalid Configuration:  The name of the date prompt was not provided.";
		}
		
		if (!sDateColumn || !(sStartDateColumn && sEndDateColumn)) {
			bValid = false;
			sMsg += "Invalid Configuration:  The name of either the date prompt or the startdate and enddate prompts are required.";
		}
		
		if (!ctrl) {
			bValid = false;
			sMsg += "Invalid configuration:  ";
			if (o["PromptName"]) {
				sMsg += "    There is not a prompt named '" + o["PromptName"] + "'.";
			}
			else {
				sMsg += "    There is not a prompt named 'PromptDate' and no prompt name was provided in the configuration.";
			}
		}
		
		if (!datastores || datastores.length != 1) {
			bValid = false;
			sMsg += "Invalid configuration:  The DateDefault custom control requires one data store.";
		}
		
		if (!bValid) {
			log("DateDefault", sMsg);
			return;
		}
		
		//	check data store(s)
		var ds = datastores[0];
		var bDateFound = false;
		var bStartDateFound = false;
		var bEndDateFound = false;
		
		for (var i = 0; i < ds.columnNames.length; i++) {
			if (sDateColumn) {
				if (ds.columnNames[i] == sDateColumn) {
					iDateCol = i;
					bDateFound = true;
					break;
				}
			}
			else {
				if (ds.columnNames[i] == sStartDateColumn) {
					iStartDateCol = i;
					bStartDateFound = true;
				}
				if (ds.columnNames[i] == sEndDateColumn) {
					iEndDateCol = i;
					bEndDateFound = true;
				}
				if (bStartDateFound && bEndDateFound) break;
			}
		}
		
		bValid = (sDateColumn && bDateFound) || (!sDateColumn && bStartDateFound && bEndDateFound);
		
		if (!bValid) {
			log("DateDefault", "The date columns defined in the configurations were not found in the data store.");
			return;
		}
		
		
		//	It's all good.  Let's get the data and validate it.
		var vals = ds.columnValues;
		if (sDateColumn) {
			for (var i = 0; i < ds.rowCount; i++) {
				if (!vals[iDateCol][i].match(reDate)) {
					sMsg += "Invalid input:  " + vals[iDateCol][i] + "is not a valid date.";
					bValid = false;
					break;
				}
			}
		}
		else {
			for (var i = 0; i < ds.rowCount; i++) {
				if (!vals[iStartDateCol][i].match(reDate)) {
					sMsg += "Invalid input:  " + vals[iStartDateCol][i] + "is not a valid date.";
					bValid = false;
					break;
				}
				if (!vals[iEndDateCol][i].match(reDate)) {
					sMsg += "Invalid input:  " + vals[iEndDateCol][i] + "is not a valid date.";
					bValid = false;
					break;
				}
			}
		}
		
		if (!bValid) {
			log("DateDefault", sMsg);
			return;
		}
		
		
		//	Data's good.  Build the array and add it to the control.
		var arrDates = [];
		if (sDateColumn) {
			for (var i = 0; i < ds.rowCount; i++) {
				arrDates.push({"use":vals[iDateCol][i]});
			}
		}
		else {
			for (var i = 0; i < ds.rowCount; i++) {
				arrDates.push({"start":{"use":vals[iStartDateCol][i]},"end":{"use":vals[iEndDateCol][i]}});
			}
		}
		oControlHost.page.getControlByName(sPromptName).setValues(arrDates);
		
		
		fnDoneInitializing();
	};
	
	return DateDefault;
});


/*
Simple values
{ 'use': '[a].[b].[c]', 'display': 'Canada' }

Range values
{
   'start': {'use': '2007-01-01', 'display': 'January 1, 2007'}
   'end': {'use': '2007-12-31', 'display': 'December 31, 2007'}
}

Multiple values
[
  { 'use': '12', 'display': 'Canada' },
  { 'use': '41', 'display': 'Germany' },
  { 'use': '76', 'display': 'Japan' }
]
*/