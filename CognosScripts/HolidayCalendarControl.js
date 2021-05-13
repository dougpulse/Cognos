define(function () {
	//	HolidayCalendar.js
	//	Holiday Calendar
	//	contains dates that are holidays
	//	provides a function to determine if a date is a holiday
	"use strict";
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	function HolidayCalendarControl() {};
	
	HolidayCalendarControl.prototype.initialize = function ( oControlHost, fnDoneInitializing ) {
		log("HolidayCalendar", "initialize" );
		this.Holidays = [];
		
		var bInit = true;
		if (bInit) fnDoneInitializing();
	};
	
	HolidayCalendarControl.prototype.setData = function( oControlHost, oDataStore ){
		log("HolidayCalendar", "setData" );
		this.m_oDataStore = oDataStore;
		this.Holidays = [];
		var iRowCount = oDataStore.rowCount;
		for ( var iRow = 0; iRow < iRowCount; iRow++ ) {
			this.Holidays.push(oDataStore.getCellValue( iRow, 0 ));
		}
	};
	
	HolidayCalendarControl.prototype.draw = function( oControlHost ){
		log("HolidayCalendar", "draw" );
	};
	
	/*
	HolidayCalendar.Holidays = [];
	HolidayCalendar.Holidays.push(new Date(2016,0,1));
	HolidayCalendar.Holidays.push(new Date(2016,0,18));
	HolidayCalendar.Holidays.push(new Date(2016,1,15));
	HolidayCalendar.Holidays.push(new Date(2016,4,30));
	HolidayCalendar.Holidays.push(new Date(2016,6,4));
	HolidayCalendar.Holidays.push(new Date(2016,8,5));
	HolidayCalendar.Holidays.push(new Date(2016,10,11));
	HolidayCalendar.Holidays.push(new Date(2016,10,24));
	HolidayCalendar.Holidays.push(new Date(2016,10,25));
	HolidayCalendar.Holidays.push(new Date(2016,11,26));
	*/
/*
Use this query against ConformedDimensions:
select 'HolidayCalendar.Holidays.push(new Date('
 + cast(datepart(year, d.FullDate) as varchar(4)) + ','
 + cast(datepart(month, d.FullDate) - 1 as varchar(2)) + ','
 + cast(datepart(day, d.FullDate) as varchar(2)) + '));'
from [Date] d
where d.LegalStateHolidayInd = 'yes'
  and year(d.FullDate) >= 2016
order by d.FullDate
*/
	HolidayCalendarControl.HolidayCalendar = function () {
		log("HolidayCalendar", "HolidayCalendar object" );
		var h = this.Holidays;
		function isHoliday (d){
			var b = false;
			d1 = new Date(d);
			d1.setHours(0);
			d1.setMinutes(0);
			d1.setSeconds(0);
			d1.setMilliseconds(0);
			//console.log(d);
			b = h.contains(d1);
			//console.log("    " + b.toString());
			return b;
		};
		return {
			isHoliday: isHoliday
		}
	};
	//HolidayCalendarControl.isHoliday = function (d) {
	//		var b = false;
	//		d1 = new Date(d);
	//		d1.setHours(0);
	//		d1.setMinutes(0);
	//		d1.setSeconds(0);
	//		d1.setMilliseconds(0);
	//		//console.log(d);
	//		b = this.Holidays.contains(d1);
	//		//console.log("    " + b.toString());
	//		return b;
	//};
	
	return HolidayCalendarControl;
});