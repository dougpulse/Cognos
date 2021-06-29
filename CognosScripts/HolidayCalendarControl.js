define(function () {
	//	HolidayCalendar.js
	//	Holiday Calendar
	//	Exposes one dataset with one category that contains the 
	//	dates of holidays appropriate to the context of the report.
	"use strict";
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	function HolidayCalendarControl() {};
	
	HolidayCalendarControl.prototype.initialize = function ( oControlHost, fnDoneInitializing ) {
		log("HolidayCalendar", "initialize" );
		
		var bInit = true;
		if (bInit) fnDoneInitializing();
	};
	
	HolidayCalendarControl.prototype.setData = function( oControlHost, oDataStore ){
		log("HolidayCalendar", "setData" );
		this.m_oDataStore = oDataStore;
	};
	
	HolidayCalendarControl.prototype.draw = function( oControlHost ){
		log("HolidayCalendar", "draw" );
	};
	
	return HolidayCalendarControl;
});