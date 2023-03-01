define(function () {
	//	HoldayCalendar.js
	//	Holiday Calendar
	//	contains dates that are holidays
	//	provides a function to determin if 
	
	function HolidayCalendar() {
	};
	
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
	HolidayCalendar.Holidays.push(new Date(2017,0,2));
	HolidayCalendar.Holidays.push(new Date(2017,0,16));
	HolidayCalendar.Holidays.push(new Date(2017,1,20));
	HolidayCalendar.Holidays.push(new Date(2017,4,29));
	HolidayCalendar.Holidays.push(new Date(2017,6,4));
	HolidayCalendar.Holidays.push(new Date(2017,8,4));
	HolidayCalendar.Holidays.push(new Date(2017,10,10));
	HolidayCalendar.Holidays.push(new Date(2017,10,23));
	HolidayCalendar.Holidays.push(new Date(2017,10,24));
	HolidayCalendar.Holidays.push(new Date(2017,11,25));
	HolidayCalendar.Holidays.push(new Date(2018,0,1));
	HolidayCalendar.Holidays.push(new Date(2018,0,15));
	HolidayCalendar.Holidays.push(new Date(2018,1,19));
	HolidayCalendar.Holidays.push(new Date(2018,4,28));
	HolidayCalendar.Holidays.push(new Date(2018,6,4));
	HolidayCalendar.Holidays.push(new Date(2018,8,3));
	HolidayCalendar.Holidays.push(new Date(2018,10,12));
	HolidayCalendar.Holidays.push(new Date(2018,10,22));
	HolidayCalendar.Holidays.push(new Date(2018,10,23));
	HolidayCalendar.Holidays.push(new Date(2018,11,25));
	HolidayCalendar.Holidays.push(new Date(2019,0,1));
	HolidayCalendar.Holidays.push(new Date(2019,0,21));
	HolidayCalendar.Holidays.push(new Date(2019,1,18));
	HolidayCalendar.Holidays.push(new Date(2019,4,27));
	HolidayCalendar.Holidays.push(new Date(2019,6,4));
	HolidayCalendar.Holidays.push(new Date(2019,8,2));
	HolidayCalendar.Holidays.push(new Date(2019,10,11));
	HolidayCalendar.Holidays.push(new Date(2019,10,28));
	HolidayCalendar.Holidays.push(new Date(2019,10,29));
	HolidayCalendar.Holidays.push(new Date(2019,11,25));
	HolidayCalendar.Holidays.push(new Date(2020,0,1));
	HolidayCalendar.Holidays.push(new Date(2020,0,20));
	HolidayCalendar.Holidays.push(new Date(2020,1,17));
	HolidayCalendar.Holidays.push(new Date(2020,4,25));
	HolidayCalendar.Holidays.push(new Date(2020,6,3));
	HolidayCalendar.Holidays.push(new Date(2020,8,7));
	HolidayCalendar.Holidays.push(new Date(2020,10,11));
	HolidayCalendar.Holidays.push(new Date(2020,10,26));
	HolidayCalendar.Holidays.push(new Date(2020,10,27));
	HolidayCalendar.Holidays.push(new Date(2020,11,25));
	HolidayCalendar.Holidays.push(new Date(2021,0,1));
	HolidayCalendar.Holidays.push(new Date(2021,0,18));
	HolidayCalendar.Holidays.push(new Date(2021,1,15));
	HolidayCalendar.Holidays.push(new Date(2021,4,31));
	HolidayCalendar.Holidays.push(new Date(2021,6,5));
	HolidayCalendar.Holidays.push(new Date(2021,8,6));
	HolidayCalendar.Holidays.push(new Date(2021,10,11));
	HolidayCalendar.Holidays.push(new Date(2021,10,25));
	HolidayCalendar.Holidays.push(new Date(2021,10,26));
	HolidayCalendar.Holidays.push(new Date(2021,11,24));
	HolidayCalendar.Holidays.push(new Date(2021,11,31));
	HolidayCalendar.Holidays.push(new Date(2022,0,17));
	HolidayCalendar.Holidays.push(new Date(2022,1,21));
	HolidayCalendar.Holidays.push(new Date(2022,4,30));
	HolidayCalendar.Holidays.push(new Date(2022,5,19));
	HolidayCalendar.Holidays.push(new Date(2022,6,4));
	HolidayCalendar.Holidays.push(new Date(2022,8,5));
	HolidayCalendar.Holidays.push(new Date(2022,10,11));
	HolidayCalendar.Holidays.push(new Date(2022,10,24));
	HolidayCalendar.Holidays.push(new Date(2022,10,25));
	HolidayCalendar.Holidays.push(new Date(2022,11,26));
	HolidayCalendar.Holidays.push(new Date(2023,0,2));
	HolidayCalendar.Holidays.push(new Date(2023,0,16));
	HolidayCalendar.Holidays.push(new Date(2023,1,20));
	HolidayCalendar.Holidays.push(new Date(2023,4,29));
	HolidayCalendar.Holidays.push(new Date(2023,5,19));
	HolidayCalendar.Holidays.push(new Date(2023,6,4));
	HolidayCalendar.Holidays.push(new Date(2023,8,4));
	HolidayCalendar.Holidays.push(new Date(2023,10,10));
	HolidayCalendar.Holidays.push(new Date(2023,10,23));
	HolidayCalendar.Holidays.push(new Date(2023,10,24));
	HolidayCalendar.Holidays.push(new Date(2023,11,25));
	HolidayCalendar.Holidays.push(new Date(2024,0,1));
	HolidayCalendar.Holidays.push(new Date(2024,0,15));
	HolidayCalendar.Holidays.push(new Date(2024,1,19));
	HolidayCalendar.Holidays.push(new Date(2024,4,27));
	HolidayCalendar.Holidays.push(new Date(2024,5,19));
	HolidayCalendar.Holidays.push(new Date(2024,6,4));
	HolidayCalendar.Holidays.push(new Date(2024,8,2));
	HolidayCalendar.Holidays.push(new Date(2024,10,11));
	HolidayCalendar.Holidays.push(new Date(2024,10,28));
	HolidayCalendar.Holidays.push(new Date(2024,10,29));
	HolidayCalendar.Holidays.push(new Date(2024,11,25));
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
	
	HolidayCalendar.isHoliday = function (d) {
			var b = false;
			d1 = new Date(d);
			d1.setHours(0);
			d1.setMinutes(0);
			d1.setSeconds(0);
			d1.setMilliseconds(0);
			//console.log(d);
			b = this.Holidays.contains(d1);
			//console.log("    " + b.toString());
			return b;
	};
	
	return HolidayCalendar;
});