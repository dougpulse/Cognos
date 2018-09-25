define(function () {

Object.extend = function(destination, source) {
	for (var property in source)
		destination[property] = source[property];
	return destination;
};

Object.extend(Object, {
	isArray: function(object) {
		return object != null && typeof object == "object" && 'splice' in object && 'join' in object;
	},
	
	isBoolean: function (object) {
		return (typeof object == "boolean" || Boolean.prototype.isPrototypeOf(object));
	},
	
	isFunction: function(object) {
		return typeof object == "function";
	},
	
	isString: function(object) {
		return typeof object == "string";
	},
	
	isNumber: function(object) {
		return typeof object == "number";
	},
	
	isUndefined: function(object) {
		return typeof object == "undefined";
	},
	
	isDate: function (object) {
		return (new Date(object)).toString() != "Invalid Date";
	},
	
	isInteger: function (object) {
		return (object.toString().search(/^-?[0-9]+$/) == 0);
	}
});

Object.extend(Array.prototype, {
	contains: function (ValueToFind) {
	/*
		Object Method:	Array.contains()
		
		Type:		JavaScript 
		Purpose:	Determine if an element with the given value exists in an array
		Inputs:		object			Required	an array object
					ValueToFind		Required	the value to find
		
		Returns:	A boolean value indicating whether an element with a value
					matching the search criteria exists.
		
		Revision History
		Date		Developer	Description
		7/31/2008	D. Pulse	original
		7/23/2018	D. Pulse	switched to using Array.some
								added the ability to compare dates
	*/
		var b = false;
		if (ValueToFind instanceof Date) {
			b = this.some(function(e) {return e.getTime() === ValueToFind.getTime()});
		}
		else {
			b = this.some(function(e) {return e == ValueToFind});
		}
		return b;
	},	//contains
	
	demote: function (index) {
	/*
		Object Method:	Array.demote()
		
		Type:		JavaScript 
		Purpose:	Provides a method for moving an element closer to the end of the array
		Inputs:		object			Required	an array object
					index			Required	index of the element to demote
		
		Returns:	(none)
		
		Revision History
		Date		Developer	Description
		6/9/2008	D. Pulse	original
	*/
		var vTemp;
		if (index < this.length - 1) {
			vTemp = this[index + 1];
			this[index + 1] = this[index];
			this[index] = vTemp;
		}
	},	//	demote
	
	promote: function (index) {
	/*
		Object Method:	Array.promote()
		
		Type:		JavaScript 
		Purpose:	Provides a method for moving an element closer to the beginning of the array
		Inputs:		object			Required	an array object
					index			Required	index of the element to promote
		
		Returns:	(none)
		
		Revision History
		Date		Developer	Description
		6/9/2008	D. Pulse	original
	*/
		var vTemp;
		if (index > 0) {
			vTemp = this[index - 1];
			this[index - 1] = this[index];
			this[index] = vTemp;
		}
	},	//	promote
	
	eq: function (arr) {
	/*
		Object Method:	Array.eq()
		
		Type:		JavaScript 
		Purpose:	Provides a method for comparing two arrays
		Inputs:		object			Required	an array object
					arr				Required	an array object
		
		Returns:	A boolean value indicating whether arr is an array, Array 
					and arr are of the same length, and Array and arr contain 
					the same values.
		
		Revision History
		Date		Developer	Description
		6/9/2008	D. Pulse	original
	*/
		if (arr instanceof Array) {
		//	Is arr and array?
			if (this.length == arr.length) {
			//	Are this array and arr of the same length
				for (var i = 0; i < this.length; i++) {
				//	Do all of the numerically-referenced values match?
					if (this[i] instanceof Array) {
						if (!this[i].eq(arr[i])) {
							return(false);
						}
					}
					else {
						if (this[i] != arr[i]) {
							return(false);
						}
					}
				}
				for (a in this) {
				//	Do all of the associatively-referenced values match?
					if (this[a] instanceof Array) {
						if (!this[a].eq(arr[a])) {
							return(false);
						}
					}
					else {
						if (this[a] != arr[a]) {
							return(false);
						}
					}
				}
				for (a in arr) {
				//	Do all of the associatively-referenced values match?
					if (this[a] instanceof Array) {
						if (!this[a].eq(arr[a])) {
							return(false);
						}
					}
					else {
						if (arr[a] != this[a]) {
							return(false);
						}
					}
				}
			}
			else {
				return(false);
			}
		}
		else {
			return(false);
		}
		return(true);
	},	//	eq
	
	indicesOf: function (value) {
	/*
		Object Method:	Array.indicesOf()
		
		Type:		JavaScript 
		Purpose:	Provides a method for locating all elements of an array
					that contain a specific value.
		Inputs:		object			Required	an array object
					value			Required	the value to match
		
		Returns:	An array containing the numeric indices of the elements
					that contain values matching the one specified.
		
		Revision History
		Date		Developer	Description
		6/9/2008	D. Pulse	original
	*/
		var a = new Array();
		for (var i = 0; i < this.length; i++) {
			if (this[i] == value) a.push(i);
		}
		return a;
	},	//	indicesOf
	
	remove: function (value, count) {
	/*
		Object Method:	Array.remove()
		
		Type:		JavaScript 
		Purpose:	Removes from the array elements whose values match the one specified.
		Inputs:		object			Required	an array object
					value			Required	the value to match
					count			Optional	The number of elements to remove.
												If count is omitted, all matching 
												elements are removed.
		
		Returns:	An array containing the numeric indices of the elements
					that contain values matching the one specified.
		
		Revision History
		Date		Developer	Description
		6/9/2008	D. Pulse	original
	*/
		var a = this.indicesOf(value);
		var n = a.length;
		if (typeof count == "number") {
			if (Math.floor(count) > 0 && Math.floor(count) < n) {
				n = Math.floor(count);
			}
		}
		a = a.slice(0, n);
		for (var i = a.length - 1; i > -1; i--) {
			this.splice(a[i], 1);
			n--;
			if (n < 1) break;
		}
		return n;
	},	//	remove
	
	unique: function(sorted) {
		var arr = [];
		for (var i = 0; i < this.length; i++) {
			if (!arr.contains(this[i])) arr.push(this[i]);
		}
		if (sorted) arr = arr.sort();
		return arr;
	},	//	unique
	
	and: function (arr) {
	/*
		Object Method:	Array.and()
		
		Type:		JavaScript 
		Purpose:	Find which elements are in both arrays.
		Inputs:		object		Required	an array object
					arr			optional	The Array object to compare to.
		
		Returns:	An array containing all of the values that are in arr and the original array.
		
		Revision History
		Date		Developer	Description
		7/9/2010	D. Pulse	original
	*/
		var arrOut = new Array();
		
		if (Array.prototype.isPrototypeOf(arr)) {
			for (var i = 0; i < this.length; i++) {
				if (arr.contains(this[i])) arrOut.push(this[i]);
			}
		}
		
		return arrOut.unique();
	},	//	and
	
	or: function (arr) {
	/*
		Object Method:	Array.or()
		
		Type:		JavaScript 
		Purpose:	Find which elements are in either array.
		Inputs:		object		Required	an array object
					arr			optional	The Array object to compare to.
		
		Returns:	An array containing all of the values that are in arr or the original array.
		
		Revision History
		Date		Developer	Description
		7/9/2010	D. Pulse	original
	*/
		var arrOut = this.clone().unique();
		
		if (Array.prototype.isPrototypeOf(arr)) {
			arrOut = this.concat(arr);
		}
		return arrOut.unique();
	},	//	or
	
	xor: function (arr) {
	/*
		Object Method:	Array.xor()
		
		Type:		JavaScript 
		Purpose:	Find which elements are in either array, but not both.
		Inputs:		object		Required	an array object
					arr			optional	The Array object to compare to.
		
		Returns:	An array containing all of the values that are in arr or the original array but not in both.
		
		Revision History
		Date		Developer	Description
		7/9/2010	D. Pulse	original
	*/
		var arrAnd = new Array();
		var arrOr = new Array();
		var arrOut = this.clone().unique();
		
		if (Array.prototype.isPrototypeOf(arr)) {
			arrOr = this.or(arr);
			arrAnd = this.and(arr);
			for (var i = 0; i < arrAnd.length; i++) {
				arrOr.remove(arrAnd[i]);
			}
			arrOut = arrOr.clone();
		}
		
		return arrOut;
	},	//	xor
	
	filterBegins: function (ValueToFind) {
		if (typeof ValueToFind == "string") {
			var arr = new Array();
			var len = ValueToFind.length;
			for (var i = 0; i < this.length; i++) {
				if (typeof this[i] == "string") {
					if (this[i].left(len) == ValueToFind) arr.push(this[i]);
				}
			}
			return arr;
		}
	}	//	filterBegins
});

Object.extend(Array.prototype, {
	//	statistical methods
	sum: function () {
	/*
		Object Method:	Array.sum()
		
		Type:		JavaScript 
		Purpose:	Sum the values in the array.
		Inputs:		object		Required	an array object
		
		Returns:	The result of summing all of the array's values.
		
		Comments:	This method is fragile.  Passing arrays containing elements of differing types
					may cause undesirable results.
					We really should check to be sure that all of the values are of the same data type
					We can sum numbers or strings (concatenate), but not objects
		
		Revision History
		Date		Developer	Description
		5/11/2010	D. Pulse	original
	*/
		var _a;
		var _type;
		var _err = false;
		
		if (this.length > 0) {
			_type = typeof this[0];
			if (_type == "number" || _type == "string") {
				for (var i = 1; i < this.length; i++) {
					if (typeof this[i] != _type) {
						_err = true;
						break;
					}
				}
				if (!_err) {
					_a = _type == "string" ? "" : 0;
					
					for (var i = 0; i < this.length; i++) {
						_a += this[i];
					}
				}
			}
		}
		return _a;
	},	//	Array.sum
	
	mean: function () {
	/*
		Object Method:	Array.mean()
		
		Type:		JavaScript 
		Purpose:	Find the arithmetic mean of an array of numbers.
		Inputs:		object		Required	an array object
		
		Returns:	A numerical value representing the mean of the array of numbers.
		
		Revision History
		Date		Developer	Description
		9/23/2010	D. Pulse	original
	*/
		//	verify that all of the array's elements are of the same type
		for (var i = 1; i < this.length; i++) {
			if ((typeof this[i]) != (typeof this[i])) return;
		}
		
		var vOut;
		
		if (typeof this[0] == "number") {
			vOut = 1.0 * this.sum() / this.length;
		}
		if (Date.prototype.isPrototypeOf(this[0])) {
			var arrDV = new Array();
			for (var i = 0; i < this.length; i++) {
				arrDV.push(this[i].valueOf());
			}
			vOut = new Date(arrDV.mean());
		}
		//	other data types are not supported
		
		return vOut;
	},	//	Array.mean
	
	median: function () {
	/*
		Object Method:	Array.median()
		
		Type:		JavaScript 
		Purpose:	Find the median value of an array of numbers.
		Inputs:		object		Required	an array object
		
		Returns:	A numerical value representing the median of the array of numbers.
		
		Revision History
		Date		Developer	Description
		9/23/2010	D. Pulse	original
	*/
		//	verify that all of the array's elements are of the same type
		for (var i = 1; i < this.length; i++) {
			if ((typeof this[i]) != (typeof this[i])) return;
		}
		
		var vOut;
		var a = this.clone();
		a.sort();
		if (typeof this[0] == "number") {
			if (this.length % 2 == 0) {
				vOut = (a[(a.length / 2) - 1] + a[a.length / 2]) / 2;
			}
			else {
				vOut = a[(a.length - 1) / 2];
			}
		}
		if (Date.prototype.isPrototypeOf(this[0])) {
			var arrDV = new Array();
			for (var i = 0; i < this.length; i++) {
				arrDV.push(this[i].valueOf());
			}
			vOut = new Date(arrDV.median());
		}
		
		return vOut;
	},	//	Array.median
	
	mode: function () {
	/*
		Object Method:	Array.mode()
		
		Type:		JavaScript 
		Purpose:	Find the mode of an array of values.
		Inputs:		object		Required	an array object
		
		Returns:	An array containing the mode(s) of the array of values.
		
		Comment:	There are 0 or more modes in a set of values.
		
		Revision History
		Date		Developer	Description
		9/23/2010	D. Pulse	original
	*/
		//	verify that all of the array's elements are of the same type
		for (var i = 1; i < this.length; i++) {
			if ((typeof this[i]) != (typeof this[i])) return;
		}
		
		var a = new Array();
		var b = new Array();
		var c = new Array();
		
		//	How many of each value?
		for (var i = 0; i < this.length; i++) {
			if (a.contains(this[i])) {
				//	the value has been seen before
				//	increment its counter
				b[a.indexOf(this[i])]++;
			}
			else {
				//	this is a new value
				//	create a counter for it
				a.push(this[i]);
				b.push(1);
			}
		}
		
		//	find the most common value
		var arrOut = new Array();
		if (b.max() == 1) {
	 
		}
		else {
			c = b.indicesOf(b.max());
			for (var i = 0; i < c.length; i++) {
				arrOut.push(a[c[i]]);
			}
		}
		
		return arrOut;
	},	//	Array.mode
	
	range: function () {
	/*
		Object Method:	Array.range()
		
		Type:		JavaScript 
		Purpose:	Find the arithmetic range of an array of numbers.
		Inputs:		object		Required	an array object
		
		Returns:	A numerical value representing the range of the array of numbers.
		
		Comment:	If the array contains dates, the return value is the number of days.
		
		Revision History
		Date		Developer	Description
		9/23/2010	D. Pulse	original
	*/
		//	verify that the array contains only numbers
		for (var i = 0; i < this.length; i++) {
			if (isNaN(this[i])) return;
		}
		
		return this.max() - this.min();
	},	//	Array.range
	
	stdDev: function (isSample) {
	/*
		Object Method:	Array.stdDev()
		
		Type:		JavaScript 
		Purpose:	Find the standard deviation of an array of numbers.
		Inputs:		object		Required	an array object
					isSample	Optional	A boolean value indicating whether the array contains sample data.
											true = sample
											false (or omitted) = population
		
		Returns:	A numerical value representing the standard deviation of the array of numbers.
		
		Revision History
		Date		Developer	Description
		4/25/2013	D. Pulse	original
	*/
		if (typeof isSample == "undefined") isSample = false;
		if (typeof isSample != "boolean") isSample = false;
		var a = isSample ? 1 : 0;
		
		//	verify that the array contains only numbers
		for (var i = 0; i < this.length; i++) {
			if (isNaN(this[i])) return -1;
			if (!Object.isNumber(this[i])) return -1;
		}
		
		var m = this.mean();
		
		var arrDelta = new Array();
		for (var i = 0; i < this.length; i++) {
			arrDelta.push((new Number(this[i].valueOf() - m)).pow(2));
		}
		
		return ( arrDelta.sum() / (this.length - a) ).pow(0.5);
	},	//	Array.stdDev
	
	V: function (isSample) {
	/*
		Object Method:	Array.V()
		
		Type:		JavaScript 
		Purpose:	Find the coefficient of variation (V) of an array of numbers.
		Inputs:		object		Required	an array object
					isSample	Optional	A boolean value indicating whether the array contains sample data.
											true = sample
											false (or omitted) = population
		
		Returns:	A numerical value representing the coefficient of variation of the array of numbers.
		
		Revision History
		Date		Developer	Description
		9/3/2013	D. Pulse	original
	*/
		if (typeof isSample == "undefined") isSample = false;
		if (typeof isSample != "boolean") isSample = false;
		return this.stdDev(isSample) * 100 / this.mean();
	},	//	Array.V
	
	skewness: function (useFisherPearson) {
	/*
		Object Method:	Array.skewness()
		
		Type:		JavaScript 
		Purpose:	Find the sample skewness of an array of numbers.
		Inputs:		object			Required	an array object
				useFisherPearson	Optional	A boolean value indicating whether to use the adjusted 
									Fisher-Pearson standardized moment coefficient, which is what is
									used by Excel and several statistical packages like Minitab, SAS 
									and SSPS.
									true = use adjusted Fisher-Pearson
									false (or omitted) = use the usual estimator
		
		Returns:	A numerical value representing the standard deviation of the array of numbers.
		Reference:	http://en.wikipedia.org/wiki/Skewness
		
		Revision History
		Date		Developer	Description
		4/25/2013	D. Pulse	original
	*/
		if (typeof useFisherPearson == "undefined") useFisherPearson = false;
		if (typeof useFisherPearson != "boolean") useFisherPearson = false;
		var m = this.mean();
		var n = this.length;
		
		if (useFisherPearson) {
			//	adjusted Fisher-Pearson
			var arrMS3 = [];
			var s = this.stdDev();
			for (var i = 0; i < this.length; i++) {
				arrMS3.push(((this[i] - m)/s).pow(3));
			}
			var ms3 = arrMS3.sum();
			var G = (n * ms3) / ((n - 1) * (n - 2));
		}
		else {
			//	usual
			var arrM3 = [];
			var arrM2 = [];
			for (var i = 0; i < this.length; i++) {
				arrM3.push((this[i] - m).pow(3));
				arrM2.push((this[i] - m).pow(2));
			}
			var m3 = arrM3.sum() / n;
			var m2 = (arrM2.sum() / n);
			var g1 = m3 / m2.pow(1.5);
			var G = ((n * (n - 1)).pow(0.5) / (n - 2)) * g1;
		}
		return G;
	},	//	Array.skewness
	
	sampleSize: function (cl, ci) {
	/*
		Object Method:	Array.sampleSize()
		
		Type:		JavaScript 
		Purpose:	Find the required sample size based on sample data.
		Inputs:		object	Required	an array object
					cl		Required	confidence level
										Z-values are hard coded so only cl = 0.95 or 0.99 is allowed.
					ci		Required	confidence interval
										Assuming results are between 0 and 1, ci must be between 0 and 0.5.
		
		Returns:	A numerical value representing the standard deviation of the array of numbers.
		Reference:	http://www.surveysystem.com/sscalc.htm#ssneeded
		
		Revision History
		Date		Developer	Description
		4/26/2013	D. Pulse	original
	*/
		var ss = new Number(0);
		if ([0.95, 0.99].contains(cl)) {
			if (typeof ci == "number") {
				if (ci > 0 && ci <= 0.5) {
					var zVal = cl == 0.95 ? 1.96 : 2.58;
					ss = (zVal * this.stdDev(true) / ci).pow(2);
				}
			}
		}
		
		return Math.round(ss);
	},	//	Array.sampleSize
	
	
	//	Given an array of points (x,y coordinates)
	//	compute the points of a trend line.
	//	These should probably be methods of a Points subclass of Array.
	
	//	linear
	TrendPointsArray: function () {
	/*
		Object Method:	Array.TrendPointsArray()
		
		Type:		JavaScript 
		Purpose:	For an array of points (2-d cartesian coordinates), find the points with the same x-ordinates along the trend line.
		Inputs:		object		Required	an array object
		
		Returns:	An array of point arrays.
					JSON.stringify([[1,1],[2,2],[3,3]].TrendPointsArray()) returns [[1,1],[2,2],[3,3]]
		
		Revision History
		Date		Developer	Description
		9/3/2013	D. Pulse	original
	*/
		var n = this.length;
		var arrOut = [];
		
		m = this.TrendSlope();
		b = this.TrendIntercept();
		
		for (var i = 0; i < n; i++) {
			arrOut.push([this[i][0], (m * this[i][0]) + b]);
		}
		
		return arrOut;
	},	//	TrendPointsArray
	
	TrendPointsObject: function () {
	/*
		Object Method:	Array.TrendPointsObject()
		
		Type:		JavaScript 
		Purpose:	For an array of points (2-d cartesian coordinates), find the points with the same x-ordinates along the trend line.
		Inputs:		object		Required	an array object
		
		Returns:	An object container containing point objects.
					JSON.stringify([[1,1],[2,2],[3,3]].TrendPointsObject()) returns {"1": 1, "2": 2, "3": 3}
		
		Revision History
		Date		Developer	Description
		9/3/2013	D. Pulse	original
	*/
		var n = this.length;
		var objOut = {};
		
		m = this.TrendSlope();
		b = this.TrendIntercept();
		
		for (var i = 0; i < n; i++) {
			objOut[this[i][0]] = (m * this[i][0]) + b;
		}
		
		return objOut;
	},	//	TrendPointsObject
	
	TrendSlope: function () {
	/*
		Object Method:	Array.TrendSlope()
		
		Type:		JavaScript 
		Purpose:	For an array of points (2-d cartesian coordinates), find the slope of the trend line.
		Inputs:		object		Required	an array object
		
		Returns:	The slope of the regression line.
		
		Reference:	http://en.wikipedia.org/wiki/Simple_linear_regression
		
		Revision History
		Date		Developer	Description
		9/5/2013	D. Pulse	original
	*/
		var x = [];
		var y = [];
		var x2 = [];
		var xy = [];
		for (var i = 0; i < this.length; i++) {
			x.push(this[i][0]);
			y.push(this[i][1]);
			x2.push(this[i][0] * this[i][0]);
			xy.push(this[i][0] * this[i][1]);
		}
		
		return (xy.mean() - x.mean() * y.mean()) / (x2.mean() - x.mean().pow(2))
	},	//	TrendSlope
	
	TrendIntercept: function () {
	/*
		Object Method:	Array.TrendIntercept()
		
		Type:		JavaScript 
		Purpose:	For an array of points (2-d cartesian coordinates), find the y-intercept of the trend line.
		Inputs:		object		Required	an array object
		
		Returns:	The y-intercept of the regression line.
		
		Reference:	http://en.wikipedia.org/wiki/Simple_linear_regression
		
		Revision History
		Date		Developer	Description
		9/5/2013	D. Pulse	original
	*/
		var y = [];
		var x = [];
		for (var i = 0; i < this.length; i++) {
			y.push(this[i][1]);
			x.push(this[i][0]);
		}
		
		return y.mean() -  (this.TrendSlope() * x.mean());
	},	//	TrendIntercept
	
	TrendCorrelationCoefficient: function () {
	//	http://www.clemson.edu/ces/phoenix/tutorials/excel/regression.html
		var r = 0;
		var n = this.length;
		var a = 0;
		var b = 0;
		var c = 0;
		var d = 0;
		var g = 0;
		var h = 0;
		var arrB = [0, 0];
		
		for (var i = 0; i < n; i++) {
			a += this[i][0] * this[i][1];
			arrB[0] += this[i][0];
			arrB[1] += this[i][1];
			c += (this[i][0] * this[i][0]);
			d += this[i][0];
			g += (this[i][1] * this[i][1]);
			h += this[i][1];
		}
		
		a *= n;
		b = arrB[0] * arrB[1];
		c *= n;
		d *= d;
		g *= n;
		h *= h;
		
		r = (a - b) / ((c - d) * (g - h));
		
		return r;
	},	//	TrendCorrelationCoefficient
	
	r: function (y) {
	//	coefficient of correlation (pearson
	//	http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient
		//	this and y must be one-dimensional arrays of numbers
		
		//	if y is not given, assume it's f (the expected values == trend line)
		if (typeof y == "undefined") {
			var a = [];
			for (var i = 0; i < this.length; i++) {
				a.push([i, this[i]]);
			}
			var f = a.TrendPointsArray();
			var y = [];
			for (var i = 0; i < f.length; i++) {
				y.push(f[i][1]);
			}
		}
		
		var x = [].concat(this);
		
		var yCheck = (y != null);
		yCheck &= (typeof y == "object");
		yCheck &= (function (c) { var bln = false; try {var q = c.splice(); bln = true;} catch (e) {}; return bln; })(y);
		yCheck &= (function (c) { var bln = false; try {var q = c.join(); bln = true;} catch (e) {}; return bln; })(y);
		if (!yCheck) return;
		//	y is an array.
		
		//	x and y must have the same number of elements
		if (x.length != y.length) return;
		
		var yBar = y.mean();
		var xBar = x.mean();
		var arrnum = [];
		var arrdx2 = [];
		var arrdy2 = [];
		for (var i = 0; i < y.length; i++) {
			arrnum.push((x[i] - xBar) * (y[i] - yBar));
			arrdx2.push((x[i] - xBar) * (x[i] - xBar));
			arrdy2.push((y[i] - yBar) * (y[i] - yBar));
		}
		var num = arrnum.sum();
		var dx2 = arrdx2.sum();
		var dy2 = arrdy2.sum();
		var denom = Math.sqrt(dx2) * Math.sqrt(dy2);
		
		return num / denom;
	},	//	r
	
	SStot: function () {
	//	total sum of squares
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
		var yVals = [];
		for (var i = 0; i < this.length; i++) {
			yVals.push(this[i][1]);
		}
		
		var yBar = yVals.mean();
		var out = 0;
		for (var i = 0; i < yVals.length; i++) {
			out += (yVals[i] - yBar) * (yVals[i] - yBar);
		}
		
		return out;
	},	//	SStot
	
	SSreg: function () {
	//	explained sum of squares
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
		var yVals = [];
		var f = this.TrendPointsArray();
		var fVals = [];
		for (var i = 0; i < this.length; i++) {
			yVals.push(this[i][1]);
			fVals.push(f[i][1]);
		}
		var yBar = yVals.mean();
		
		var out = 0;
		
		for (var i = 0; i < fVals.length; i++) {
			out += (fVals[i] - yBar) * (fVals[i] - yBar);
		}
		
		return out;
	},	//	SSreg
	
	SSres: function () {
	//	residual sum of squares
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
		var yVals = [];
		var f = this.TrendPointsArray();
		var fVals = [];
		for (var i = 0; i < this.length; i++) {
			yVals.push(this[i][1]);
			fVals.push(f[i][1]);
		}
		
		var out = 0;
		
		for (var i = 0; i < yVals.length; i++) {
			out += (fVals[i] - yVals[i]) * (fVals[i] - yVals[i]);
		}
		
		return out;
	},	//	SSres
	
	R2: function () {
	//	coefficient of determination
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
	//	this.r() * this.r() works well, too
		return 1 - (this.SSres() / this.SStot());
	}	//	R2
});

PointsArray = function (array1, array2) {
	var _array = [];
	var blnGood = false;
	//	case 1:		no arguments are passed
	if (arguments.length == 0) {
		blnGood = true;
	}
	//	case 2:		array1 is an array of 2-element arrays containing numbers, array2 is ignored
	else if (arguments.length == 1 && Object.isArray(array1)) {
		if (array1.length == 0) {
			blnGood = true;
		}
		else {
			blnGood = true;
			for (var i = 0; i < array1.length; i++) {
				if (!Object.isArray(array1[i])) {
					blnGood = false;
					continue;
				}
				if (array1[i].length != 2) {
					blnGood = false;
					continue;
				}
				if (!Object.isNumber(array1[i][0]) || !Object.isNumber(array1[i][0])) {
					blnGood = false;
					continue;
				}
			}
			if (blnGood) _array = array1;
		}
	}
	//	case 3:		array1 and array2 are both 1-dimensional arrays of numbers.
	//				They must have the same number of elements.
	else {
		if (Object.isArray(array1) && Object.isArray(array1)) {
			if (array1.length == array2.length && array1.length) {
				if (array1.length == 0) {
					blnGood = true;
				}
				else {
					for (var i = 0; i < array1.length; i++) {
						if (!Object.isNumber(array1[i]) || !Object.isNumber(array2[i])) {
							blnGood = false;
							_array = [];
							continue
						}
						_array.push([array1[i],array2[i]]);
					}
				}
			}
		}
	}
	
	this.toArray = function () {
		return _array;
	} 
	
	this.add = function (array) {
		//	array must be a 2-element array of numbers
		if (Object.isArray(array)) {
			if (array.length == 2) {
				if (Object.isNumber(array[0]) && Object.isNumber(array[1])) {
					_array.push(array);
				}
			}
		}
	} 
	
	var sortFn = function (a, b) {
		//	a and b are 2-element arrays of numbers
		if (a[0] > b[0]) return -1;
		if (a[0] < b[0]) return 1;
		if (a[1] > b[1]) return -1;
		if (a[1] < b[1]) return 1;
		return 0;
	}
	
	this.sort = function () {
		return _array.sort(this.sortFn);
	}
	
	this.length = function () {
		return _array.length;
	}
	
	this.xVals = function () {
		var x = [];
		for (var i = 0; i < _array.length; i++) {
			x.push(_array[i][0]);
		}
		return x;
	}
	
	this.yVals = function () {
		var y = [];
		for (var i = 0; i < _array.length; i++) {
			y.push(_array[i][1]);
		}
		return y;
	}
	
	this.TrendSlope = function () {
	/*
		Object Method:	PointsArray.TrendSlope()
 
		Type:		JavaScript 
		Purpose:	For an array of points (2-d cartesian coordinates), find the slope of the trend line.
		Inputs:		object		Required	an array object
 
		Returns:	The slope of the regression line.
 
		Reference:	http://en.wikipedia.org/wiki/Simple_linear_regression
 
		Revision History
		Date		Developer	Description
		9/5/2013	D. Pulse	original
	*/
		var x = [];
		var y = [];
		var x2 = [];
		var xy = [];
		for (var i = 0; i < _array.length; i++) {
			x.push(_array[i][0]);
			y.push(_array[i][1]);
			x2.push(_array[i][0] * _array[i][0]);
			xy.push(_array[i][0] * _array[i][1]);
		}
 
		return (xy.mean() - x.mean() * y.mean()) / (x2.mean() - x.mean().pow(2))
	}, 	//	TrendSlope
	
	this.TrendIntercept = function () {
	/*
		Object Method:	PointsArray.TrendIntercept()
 
		Type:		JavaScript 
		Purpose:	For an array of points (2-d cartesian coordinates), find the y-intercept of the trend line.
		Inputs:		object		Required	an array object
 
		Returns:	The y-intercept of the regression line.
 
		Reference:	http://en.wikipedia.org/wiki/Simple_linear_regression
 
		Revision History
		Date		Developer	Description
		9/5/2013	D. Pulse	original
	*/
		var y = [];
		var x = [];
		for (var i = 0; i < _array.length; i++) {
			y.push(_array[i][1]);
			x.push(_array[i][0]);
		}
 
		return y.mean() -  (this.TrendSlope() * x.mean());
	}, 	//	TrendIntercept
	
	this.TrendPointsArray = function () {
	/*
		Object Method:	Array.TrendPointsArray()
	
		Type:		JavaScript 
		Purpose:	For an array of points (2-d cartesian coordinates), find the points with the same x-ordinates along the trend line.
		Inputs:		object		Required	an array object
		
		Returns:	An array of point arrays.
					JSON.stringify([[1,1],[2,2],[3,3]].TrendPointsArray()) returns [[1,1],[2,2],[3,3]]
		
		Revision History
		Date		Developer	Description
		9/3/2013	D. Pulse	original
	*/
		var n = _array.length;
		var arrOut = [];
		
		m = this.TrendSlope();
		b = this.TrendIntercept();
		
		for (var i = 0; i < n; i++) {
			//arrOut.push([_array[i][0], (m * _array[i][0]) + b]);
			arrOut.push([_array[i][0], ((m * _array[i][0]) + b).round(10)]);	//	round to correct for binary math
		}
		
		var paOut = new PointsArray(arrOut);
		return paOut;
	} 	//	TrendPointsArray
	
	this.SStot = function () {
	//	total sum of squares
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
		var yVals = [];
		for (var i = 0; i < _array.length; i++) {
			yVals.push(_array[i][1]);
		}
		
		var yBar = yVals.mean();
		var out = 0;
		for (var i = 0; i < yVals.length; i++) {
			out += (yVals[i] - yBar) * (yVals[i] - yBar);
		}
		
		return out;
	} 	//	SStot
	
	this.SSreg = function () {
	//	explained sum of squares
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
		var yVals = [];
		var f = this.TrendPointsArray().toArray();
		var fVals = [];
		for (var i = 0; i < _array.length; i++) {
			yVals.push(_array[i][1]);
			fVals.push(f[i][1]);
		}
		var yBar = yVals.mean();
		
		var out = 0;
		
		for (var i = 0; i < fVals.length; i++) {
			out += (fVals[i] - yBar) * (fVals[i] - yBar);
		}
		
		return out;
	} 	//	SSreg
	
	this.SSres = function () {
	//	residual sum of squares
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
		var yVals = [];
		var f = this.TrendPointsArray().toArray();
		var fVals = [];
		for (var i = 0; i < _array.length; i++) {
			yVals.push(_array[i][1]);
			fVals.push(f[i][1]);
		}
		
		var out = 0;
	
		for (var i = 0; i < yVals.length; i++) {
			out += (fVals[i] - yVals[i]) * (fVals[i] - yVals[i]);
		}
		
		return out;
	} 	//	SSres
	
	this.r = function () {
	//	coefficient of correlation (pearson
	//	http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient
		
		var x = this.yVals();
		var y = this.TrendPointsArray().yVals();
		
		var yCheck = (y != null);
		yCheck &= (typeof y == "object");
		yCheck &= (function (c) { var bln = false; try {var q = c.splice(); bln = true;} catch (e) {}; return bln; })(y);
		yCheck &= (function (c) { var bln = false; try {var q = c.join(); bln = true;} catch (e) {}; return bln; })(y);
		if (!yCheck) return;
		//	y is an array.
		
		//	x and y must have the same number of elements
		if (x.length != y.length) return;
		
		var yBar = y.mean();
		var xBar = x.mean();
		var arrnum = [];
		var arrdx2 = [];
		var arrdy2 = [];
		for (var i = 0; i < y.length; i++) {
			arrnum.push((x[i] - xBar) * (y[i] - yBar));
			arrdx2.push((x[i] - xBar) * (x[i] - xBar));
			arrdy2.push((y[i] - yBar) * (y[i] - yBar));
		}
		var num = arrnum.sum();
		var dx2 = arrdx2.sum();
		var dy2 = arrdy2.sum();
		var denom = Math.sqrt(dx2) * Math.sqrt(dy2);
		
		return num / denom;
	} 	//	r
	
	this.R2 = function () {
	//	coefficient of determination
	//	http://en.wikipedia.org/wiki/Coefficient_of_determination
	//	this.r() * this.r() works well, too
		return 1 - (this.SSres() / this.SStot());
	}	//	R2
}

Object.extend(String.prototype, {
	column: function (width, just) {
		var s = this.toString();
		if (typeof width == "number") {
			if (typeof just == "undefined") {
				just = 0;
			}
			if (typeof just == "number") {
				if ((new Array(0, 1)).contains(just) && width > 0) {
					if (just == 0) {
						s += s.space(width);
						s = s.substr(0, width);
					}
					if (just == 1) {
						s = s.space(width) + s;
						s = s.substr(s.length - width);
					}
				}
			}
		}
		return s;
	},	//	column
	
	isNumeric: function () {
		if (isNaN(parseFloat(this))) {
			return false;
		}
		return true;
	},	//	isNumeric
	
	isInteger: function() {
		return Object.isInteger(this);
	},	//	isInteger
	
	reverse: function() {
	/*
		Object Method: String.reverse()
		
		Type: 		JavaScript 
		Purpose:	Provides a method for a String object to returns a string 
					in which the character order of the string is reversed.
		
		Inputs: 	(none)
		
		Returns:	string
		Modification History:
		Date		Developer	Description
		1/16/2008	Doug Pulse		Original
	*/
	  for( var oStr = "", x = this.length - 1, oTmp; oTmp = this.charAt(x); x-- ) {
		oStr += oTmp;
	  }
	  return oStr;
	},	//	reverse
	
	lTrim: function() {
	/*
		Object Method: String.lTrim()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the String object to 
					return a copy of a string without leading spaces.
		
		Inputs:		(none)
		
		Returns:	string
		Modification History:
		Date		Developer		Description
		1/16/2008	Doug Pulse		Original
	*/
		var whitespace = new String(" \t\n\r");
		
		var s = new String(this);
		
		if (whitespace.indexOf(s.charAt(0)) != -1) {
			// We have a string with leading blank(s)...
			
			var j = 0, i = s.length;
			
			// Iterate from the far left of string until we
			// don't have any more whitespace...
			while (j < i && whitespace.indexOf(s.charAt(j)) != -1)
				j++;
			
			// Get the substring from the first non-whitespace
			// character to the end of the string...
			s = s.substring(j, i);
		}
	 
		return s;
	},	//	lTrim
	
	rTrim: function() {
	/*
		Object Method: String.rTrim()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the String object to 
					return a copy of a string without trailing spaces.
		
		Inputs: 	(none)
		
		Returns:	string
		Modification History:
		Date		Developer		Description
		1/16/2008	Doug Pulse		Original
	*/
		// We don't want to trim JUST spaces, but also tabs,
		// line feeds, etc.  Add anything else you want to
		// "trim" here in Whitespace
		var whitespace = new String(" \t\n\r");
		
		var s = new String(this);
		
		if (whitespace.indexOf(s.charAt(s.length - 1)) != -1) {
			// We have a string with trailing blank(s)...
			
			var i = s.length - 1;       // Get length of string
			
			// Iterate from the far right of string until we
			// don't have any more whitespace...
			while (i >= 0 && whitespace.indexOf(s.charAt(i)) != -1)
				i--;
			
			// Get the substring from the front of the string to
			// where the last non-whitespace character is...
			s = s.substring(0, i + 1);
		}
		
		return s;
	},	//	rTrim
	
	space: function (width) {
		var s = "";
		if (typeof width == "number") {
			if (width > 0) {
				for (var i = 0; i < width; i++) {
					s += " ";
				}
			}
		}
		return s;
	},	//	space
	
	trim: function() {
	/*
		Object Method: String.trim()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the String object to 
					return a copy of a string without leading or trailing spaces.
		
		Inputs:		(none)
		
		Returns:	string
		Modification History:
		Date		Developer		Description
		1/16/2008	Doug Pulse		Original
	*/
	 return this.lTrim().rTrim();
	},	//	trim
	
	left: function(n) {
	/*
		Object Method: String.left()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the String object to return a specified 
					number of characters from the left side of a string.
		
		Inputs: 	length	Numeric expression indicating how many characters to 
							return. If 0, a zero-length string("") is returned. If 
							greater than or equal to the number of characters in 
							string, the entire string is returned.
		
		Returns:	string
		
		Modification History:
		Date		Developer		Description
		1/16/2008	Doug Pulse		Original
	*/
		return this.substr(0, n);
	},	//	left
	
	right: function(n) {
	/*
		Object Method: String.right()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the String object to return a specified 
					number of characters from the right side of a string.
		
		Inputs: 	length	Numeric expression indicating how many characters to 
							return. If 0, a zero-length string("") is returned. If 
							greater than or equal to the number of characters in 
							string, the entire string is returned.
		
		Returns:	string
		
		Modification History:
		Date		Developer		Description
		1/16/2008	Doug Pulse		Original
	*/
		return this.substr(this.length - n);
	},	//	right
	
	times: function (n) {
		//	returns the string repeated n times
		
		var sOut = "";
		for (var i = 0; i < n; i++) {
			sOut += this.valueOf()
		}
		return sOut;
	},	//	times
	
	inStr: function(intStart, strSearchFor, blnCompare) {
	/*
		Name:		inStr
		Purpose:	provide a String method with the same functionality as the VBScript InStr function.
		Returns:	the position of the first occurrence of one string within another
		Inputs:		intStart		Numeric expression that sets the starting position for each search.
					strSearchFor	String expression searched for.
					blnCompare		0 = binary comparison, 1 = text comparison
		
		Notes:	vbscript instr function is 1-based
				this javascript instr function is 0-based
		
		Revision History
		Date		Developer		Description
		1/16/2008	D. Pulse		inagural
	*/
			var intLoc = -1;
			var strSearch = new String(this);
			if (arguments[2] == undefined) 
					blnCompare = 0;
			if (blnCompare == 1) {
					strSearch = strSearch.toLowerCase();
					strSearchFor = strSearchFor.toLowerCase();
			}
			
			intLoc = strSearch.substr(intStart).indexOf(strSearchFor);
			
			if (intLoc > -1) {
					intLoc += intStart;
			}
			return(intLoc);
	},	//	inStr
	
	parseInt: function (radix) {
		return parseInt(this, radix);
	},	//	parseInt
	
	toPascalCase: function () {
		var arr = this.toProperCase().replace(/[ _\-\t]+/gi, " ").split(" ");
		
		for (var i = 0; i < arr.length; i++) {
			arr[i] = arr[i].substr(0, 1).toUpperCase() + arr[i].substr(1);
		}
		
		return arr.join("");
	},	//	toPascalCase
	
	toCamelCase: function () {
		var arr = this.toProperCase().replace(/[ _\-\t]+/gi, " ").split(" ");
		
		arr[0] = arr[0].toLowerCase();
		
		for (var i = 1; i < arr.length; i++) {
			arr[i] = arr[i].substr(0, 1).toUpperCase() + arr[i].substr(1);
		}
		
		return arr.join("");
	},	//	toCamelCase
	
	toUnderscoreCase: function () {
		return this.toProperCase().replace(/[ _\-\t]+/gi, "_");
	},	//	toUnderscoreCase
	
	toDashCase: function () {
		return this.toProperCase().replace(/[ _\-\t]+/gi, "-");
	},	//	toDashCase
	
	toProperCase: function () {
		return this.replace(/[_\- ]/g, " ").replace(/([A-Z]+)([A-Z])([a-z0-9,]+)/g, "$1 $2$3").replace(/([^A-Z ])([A-Z])/g, "$1 $2");
	},	//	toProperCase
	
	toSentenceCase: function () {
		var arr = this.toProperCase().replace(/[ _\-\t]+/gi, " ").split(" ");
		
		arr[0] = arr[0].substr(0, 1).toUpperCase() + arr[0].substr(1);
		
		for (var i = 1; i < arr.length; i++) {
			arr[i] = arr[i].toLowerCase();
		}
		
		return arr.join(" ");
	}	//	toSentenceCase
});

Number.range = function() {
	/*
		Behaves just like the python range() built-in function.
		Arguments:   [start,] stop[, step]
		
		@start   Number  start value
		@stop    Number  stop value (excluded from result)
		@step    Number  skip values by this step size
		
		Number.range() -> error: needs more arguments
		Number.range(4) -> [0, 1, 2, 3]
		Number.range(0) -> []
		Number.range(0, 4) -> [0, 1, 2, 3]
		Number.range(0, 4, 1) -> [0, 1, 2, 3]
		Number.range(0, 4, -1) -> []
		Number.range(4, 0, -1) -> [4, 3, 2, 1]
		Number.range(0, 4, 5) -> [0]
		Number.range(5, 0, 5) -> []
		Number.range(5, 4, 1) -> []
		Number.range(0, 1, 0) -> error: step cannot be zero
		Number.range(0.2, 4.0) -> [0, 1, 2, 3]
	*/
	var start, end, step;
	var array = [];
	
	switch(arguments.length){
		case 0:
			throw new Error('range() expected at least 1 argument, got 0 - must be specified as [start,] stop[, step]');
			return array;
		case 1:
			start = 0;
			end = Math.floor(arguments[0]) - 1;
			step = 1;
			break;
		case 2:
		case 3:
		default:
			start = Math.floor(arguments[0]);
			end = Math.floor(arguments[1]) - 1;
			var s = arguments[2];
			if (typeof s === 'undefined'){
				s = 1;
			}
			step = Math.floor(s) || (function(){ throw new Error('range() step argument must not be zero'); })();
			break;
	}
	
	if (step > 0) {
		for (var i = start; i <= end; i += step){
			array.push(i);
		}
	}
	else if (step < 0) {
		step = -step;
		if (start > end) {
			for (var i = start; i > end + 1; i -= step) {
				array.push(i);
			}
		}
	}
	return array;
}	//	range


Object.extend(Number.prototype, {
	format: function (NumDigitsAfterDecimal, IncludeLeadingDigit, UseParensForNegativeNumbers, GroupDigits) {
	/*
		Object Method: Number.format()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the Number object to display a number in a specific format.
		Inputs:		object						Required	a Number object
					NumDigitsAfterDecimal		Optional	the number of decimal places to format the number to
					IncludeLeadingDigit			Optional	true / false - display a leading zero for
															numbers between -1 and 1
					UseParensForNegativeNumbers	Optional	true / false - use parenthesis around negative numbers
					GroupDigits					Optional	put commas as number separators.
		
		Returns:	A string containing the formatted number.
		Modification History:
		Date		Developer		Description
		1/16/2008	Doug Pulse		Original
	*/
		if (typeof NumDigitsAfterDecimal == "undefined") NumDigitsAfterDecimal = 0;
		if (typeof IncludeLeadingDigit == "undefined") IncludeLeadingDigit = true;
		if (typeof UseParensForNegativeNumbers == "undefined") UseParensForNegativeNumbers = false;
		if (typeof GroupDigits == "undefined") GroupDigits = false;
		
		if (isNaN(this.valueOf())) return "NaN";
		
		var tmpNum = this.valueOf();
		var iSign = this.valueOf() < 0 ? -1 : 1;		// Get sign of number
		
		// Adjust number so only the specified number of numbers after
		// the decimal point are shown.
		tmpNum *= Math.pow(10, NumDigitsAfterDecimal);
		tmpNum = Math.round(Math.abs(tmpNum));
		tmpNum /= Math.pow(10, NumDigitsAfterDecimal);
		tmpNum *= iSign;					// Readjust for sign
		
		// Create a string object to do our formatting on
		var tmpNumStr = new String(tmpNum);
		
		if (tmpNumStr.indexOf(".") == -1)
			tmpNumStr += ".";
		
		while ((tmpNumStr.length - tmpNumStr.lastIndexOf(".") - 1) != NumDigitsAfterDecimal) {
			tmpNumStr += "0";
		}
		
		// See if we need to strip out the leading zero or not.
		if (!IncludeLeadingDigit && this.valueOf() < 1 && this.valueOf() > -1 && this.valueOf() != 0)
			if (this.valueOf() > 0)
				tmpNumStr = tmpNumStr.substring(1, tmpNumStr.length);
			else
				tmpNumStr = "-" + tmpNumStr.substring(2, tmpNumStr.length);
		
		// See if we need to put in the commas
		if (GroupDigits && (this.valueOf() >= 1000 || this.valueOf() <= -1000)) {
			var iStart = tmpNumStr.indexOf(".");
			if (iStart < 0)
				iStart = tmpNumStr.length;
			
			iStart -= 3;
			while (iStart >= 1) {
				tmpNumStr = tmpNumStr.substring(0, iStart) + "," + tmpNumStr.substring(iStart, tmpNumStr.length);
				iStart -= 3;
			}
		}
		
		// See if we need to use parenthesis
		if (UseParensForNegativeNumbers && this.valueOf() < 0)
			tmpNumStr = "(" + tmpNumStr.substring(1, tmpNumStr.length) + ")";
		
		// Make sure the number doesn't end with a decimal point
		if (tmpNumStr.substr(tmpNumStr.length - 1, 1) == ".")
			tmpNumStr = tmpNumStr.substr(0, tmpNumStr.length - 1);
		
		return tmpNumStr;		// Return our formatted string!
	},	//	format
	
	currencyFormat: function (NumDigitsAfterDecimal, IncludeLeadingDigit, UseParensForNegativeNumbers, GroupDigits) {
	/*
		Object Method:	Number.currencyFormat()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the Number object to display a number as currency.
		Inputs:		object						Required	a Number object
					NumDigitsAfterDecimal		Optional	the number of decimal places to format the number to
					IncludeLeadingDigit			Optional	true / false - display a leading zero for
															numbers between -1 and 1
					UseParensForNegativeNumbers	Optional	true / false - use parenthesis around negative numbers
					GroupDigits					Optional	put commas as number separators.
		
		Returns:	A string containing the number formatted as currency.
		
		Revision History
		Date		Developer	Description
	*/
		var tmpStr = new String(this.format(NumDigitsAfterDecimal, IncludeLeadingDigit, UseParensForNegativeNumbers, GroupDigits));
		
		if (tmpStr.indexOf("(") != -1 || tmpStr.indexOf("-") != -1) {
			// We know we have a negative number, so place '$' inside of '(' / after '-'
			if (tmpStr.charAt(0) == "(")
				tmpStr = "($"  + tmpStr.substring(1,tmpStr.length);
			else if (tmpStr.charAt(0) == "-")
				tmpStr = "-$" + tmpStr.substring(1,tmpStr.length);
			
			return tmpStr;
		}
		else
			return "$" + tmpStr;		// Return formatted string!
	},	//	currencyFormat
	
	percentFormat: function (NumDigitsAfterDecimal, IncludeLeadingDigit, UseParensForNegativeNumbers, GroupDigits) {
	/*
		Object Method:	Number.percentFormat()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the Number object to display a number as a percent in a specific format.
		Inputs:		object						Required	a Number object
					NumDigitsAfterDecimal		Optional	the number of decimal places to format the number to
					IncludeLeadingDigit			Optional	true / false - display a leading zero for
															numbers between -1 and 1
					UseParensForNegativeNumbers	Optional	true / false - use parenthesis around negative numbers
					GroupDigits					Optional	put commas as number separators.
		
		Returns:	A string containing the number formatted as a percent
		Modification History:
		Date		Developer		Description
		1/16/2008	Doug Pulse		Original
	*/
		var tmpStr = new String((this * 100).format(NumDigitsAfterDecimal, IncludeLeadingDigit, UseParensForNegativeNumbers, GroupDigits));
		
		if (tmpStr.indexOf(")") != -1) {
			// We know we have a negative number, so place '%' inside of ')'
			tmpStr = tmpStr.substring(0, tmpStr.length - 1) + "%)";
			return tmpStr;
		}
		else
			return tmpStr + "%";			// Return formatted string!
	},	//	percentFormat
	
	stringFormat: function (NumberFormat) {
	/*
		Object Method:	Number.stringFormat()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the Number object to display 
					a number in a specific format.
		Inputs:		object			Required	a Number object
					NumberFormat	Required	the string pattern defining how to format the number
												eg. "$#,##0"
		
		Returns:	A string containing the formatted number.
		
		Revision History
		Date		Developer	Description
	*/
		var iLoc;
		
		//if (NumberFormat.inStr(0, ",") != -1) 
		//	GroupDigits = 1;
		
		var strTemp = NumberFormat.replace(/(\#|0|,|.|\$)/gi, "");
		if (strTemp.length > 0) 
			return("Invalid number format");
		
		iLoc = NumberFormat.inStr(0, ".")
		if (iLoc != -1) {
			NumDigitsAfterDecimal = NumberFormat.length - iLoc - 1;
		}
		else {
			NumDigitsAfterDecimal = 0;
		}
		
		if (NumberFormat.substr(0, iLoc).inStr(0, "0") != 0) {
			IncludeLeadingDigit = 1;
		}
		else {
			IncludeLeadingDigit = 1;
		}
		
		iLoc = NumberFormat.inStr(0, ",")
		if (iLoc != -1) {
			GroupDigits = 1;
		}
		else {
			GroupDigits = 0;
		}
		
		iLoc = NumberFormat.inStr(0, "(")
		if (iLoc != -1) {
			UseParensForNegativeNumbers = 1;
		}
		else {
			UseParensForNegativeNumbers = 0;
		}
		
		iLoc = NumberFormat.inStr(0, "$")
		if (iLoc != -1) {
			return(this.currencyFormat(NumDigitsAfterDecimal, IncludeLeadingDigit, UseParensForNegativeNumbers, GroupDigits));
		}
		else {
			return(this.format(NumDigitsAfterDecimal, IncludeLeadingDigit, UseParensForNegativeNumbers, GroupDigits));
		}
	},	//	stringFormat
	
	pow: function (n) {
		return Math.pow(this, n);
	},	//	pow
	
	round: function(places) {
		if (typeof places == "undefined") {
			return(Math.round(this));
		}
		else if (typeof places == "number") {
			return Math.round(this * Math.pow(10, places)) / Math.pow(10, places);
		}
		else {
			return;
		}
	},	//	round
	
	abs: function () {
		return Math.abs(this);
	},	//	abs
	
	ceil: function () {
		return Math.ceil(this);
	},	//	ceil
	
	floor: function () {
		return Math.floor(this);
	},	//	floor
	
	ordinalSuffix: function () {
		var suffix = "th";
		if (Number.isInteger(this * 1.0)) {
			switch (this % 10) {
				case 1:
					suffix = "st";
					break;
				case 2:
					suffix = "nd";
					break;
				case 3:
					suffix = "rd";
					break;
				default:
					suffix = "th";
					break;
			}
		}
		return suffix;
	},	//	ordinalSuffix
	
	ordinal: function () {
		return this + this.ordinalSuffix;
	},	//	ordinal
	
	toBinary: function(precision) {
		//	IEEE 754
		//	see tutorial at http://kipirvine.com/asm/workbook/floating_tut.htm
		//	see info at https://en.wikipedia.org/wiki/IEEE_floating_point
		//	
		//	precision (see length in table below)
		//		length	sign	exponent	mantissa	exponent bias	name
		//		16		1		5			10			15				half precision
		//		32		1		8			23			127				single precision
		//		64		1		11			52			1023			double precision
		//		128		1		15			112			16383			quadruple precision
		//	
		//	output format
		//		sign	exponent	mantissa
		//		1		5			10		
		//		1		8			23		
		//		1		11			52		
		//		1		15			112		
		//
		
		var sign = this < 0 ? "1" : "0";
		var exp = "";
		var man = "";
		var prec = [];
		prec[16] = [5, 10, 15];
		prec[32] = [8, 23, 127];
		prec[64] = [11, 52, 1023];
		prec[128] = [15, 112, 16383];
		
		//	precision defaults to "single"
		if (typeof precision == "undefined") precision = 32;
		if (!Object.isInteger(precision)) precision = 32;
		if (![16, 32, 64, 128].contains(precision)) precision = 32;
		
		var n = this.valueOf().abs().floor();
		var m = 0;
		var blnFoundOne = false;
		
		//	deal with digits to the left of the decimal point first
		if (n >= 1.0) {
			man = n.toBin();									//	get the raw binary representation of the integer portion
			exp = (prec[precision][2] + man.length).toBin();	//	adjusted exponent
			man = man.substr(1);								//	drop the first 1
		}
		
		//	now the digits to the right of the decimal point
		if (this != this.floor()) {
			n = (this - (n * (-1).pow(sign.parseInt()))).abs();
			m = prec[precision][1];
			for (var i = -1; i >= -m; i--) {
				//	we need 23 or 52 digits
				//	>= makes the first 1 not count
				if (n >= (2).pow(i)) {
					blnFoundOne = true;
					man += "1";
					n -= (2).pow(i);
				}
				else {
					man += "0";
					if (!blnFoundOne) m++;						//	we need 23 or 52 digits.  leading 0's don't count
				}
			}
			if (exp == "") {
				//	there was nothing to the left of the decimal point
				exp = man.indexOf("1") + 1;						//	find the first 1
				man = man.substr(exp);							//	move the "point" to just after the first 1
				exp = (prec[precision][2] - exp).toBin();		//	adjusted exponent
			}
		}
		exp = "0".times(prec[precision][0]) + exp;
		exp = exp.substr(exp.length - prec[precision][0]);
		man += "0".times(prec[precision][1]);
		man = man.substr(0, prec[precision][1]);
		
		return sign + " " + exp + " " + man;
	},	//	toBinary
	
	toBin: function() {
		//	used to convert positive integers to binary
		//	it does not provide leading 
		var sOut = "";
		if (Object.isInteger(this)) {
			var n = this;
			var a = n.floor();
			var b = 0;
			var c = "";
			if (n >= 1.0) {
				while (a > 0) {
					b = a % 2;
					c = b.toString() + c;
					a = (a / 2).floor();
				}
			}
			sOut = c;
		}
		
		return sOut;
	},	//	toBin
	
	toPaddedString:  function(length, radix) {
	/*
		Object Method:	Number.toPaddedString()
		
		Type:		JavaScript 
		Purpose:	Provides a method for the Number object to display a number as a percent in a specific format.
		Inputs:		object						Required	a Number object
					length		Required	the number of digits to output
					radix		Optional	the base.  defaults to 10 (decimal)
		
		Returns:	A string containing the number formatted as a percent
		Modification History:
		Date		Developer		Description
		12/21/2016	Doug Pulse		Original
	*/
		var string = this.toString(radix || 10);
		return '0'.times(length - string.length) + string;
	}	//	toPaddedString
});



Date.WeekdayName = ["Sunday", "Monday", "Tuesday", "Wednesday","Thursday", "Friday", "Saturday"];
Date.WeekdayAbbrev = ["Sun", "Mon", "Tue", "Wed","Thu", "Fri", "Sat"];
Date.MonthName = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
Date.MonthAbbrev = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//HolidayCalendar = {};
//HolidayCalendar.Holidays = [];
//HolidayCalendar.Holidays.push(new Date(2016,0,1));
//HolidayCalendar.Holidays.push(new Date(2016,0,18));
//HolidayCalendar.Holidays.push(new Date(2016,1,15));
//HolidayCalendar.Holidays.push(new Date(2016,4,30));
//HolidayCalendar.Holidays.push(new Date(2016,6,4));
//HolidayCalendar.Holidays.push(new Date(2016,8,5));
//HolidayCalendar.Holidays.push(new Date(2016,10,11));
//HolidayCalendar.Holidays.push(new Date(2016,10,24));
//HolidayCalendar.Holidays.push(new Date(2016,10,25));
//HolidayCalendar.Holidays.push(new Date(2016,11,26));
//HolidayCalendar.Holidays.push(new Date(2017,0,2));
//HolidayCalendar.Holidays.push(new Date(2017,0,16));
//HolidayCalendar.Holidays.push(new Date(2017,1,20));
//HolidayCalendar.Holidays.push(new Date(2017,4,29));
//HolidayCalendar.Holidays.push(new Date(2017,6,4));
//HolidayCalendar.Holidays.push(new Date(2017,8,4));
//HolidayCalendar.Holidays.push(new Date(2017,10,10));
//HolidayCalendar.Holidays.push(new Date(2017,10,23));
//HolidayCalendar.Holidays.push(new Date(2017,10,24));
//HolidayCalendar.Holidays.push(new Date(2017,11,25));
//HolidayCalendar.Holidays.push(new Date(2018,0,1));
//HolidayCalendar.Holidays.push(new Date(2018,0,15));
//HolidayCalendar.Holidays.push(new Date(2018,1,19));
//HolidayCalendar.Holidays.push(new Date(2018,4,28));
//HolidayCalendar.Holidays.push(new Date(2018,6,4));
//HolidayCalendar.Holidays.push(new Date(2018,8,3));
//HolidayCalendar.Holidays.push(new Date(2018,10,12));
//HolidayCalendar.Holidays.push(new Date(2018,10,22));
//HolidayCalendar.Holidays.push(new Date(2018,10,23));
//HolidayCalendar.Holidays.push(new Date(2018,11,25));
//HolidayCalendar.Holidays.push(new Date(2019,0,1));
//HolidayCalendar.Holidays.push(new Date(2019,0,21));
//HolidayCalendar.Holidays.push(new Date(2019,1,18));
//HolidayCalendar.Holidays.push(new Date(2019,4,27));
//HolidayCalendar.Holidays.push(new Date(2019,6,4));
//HolidayCalendar.Holidays.push(new Date(2019,8,2));
//HolidayCalendar.Holidays.push(new Date(2019,10,11));
//HolidayCalendar.Holidays.push(new Date(2019,10,28));
//HolidayCalendar.Holidays.push(new Date(2019,10,29));
//HolidayCalendar.Holidays.push(new Date(2019,11,25));
//HolidayCalendar.isHoliday = function (d) {
//	var b = false;
//	d1 = new Date(d);
//	d1.setHours(0);
//	d1.setMinutes(0);
//	d1.setSeconds(0);
//	d1.setMilliseconds(0);
//	//console.log(d);
//	b = this.Holidays.contains(d1);
//	//console.log("    " + b.toString());
//	return b;
//};

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


Object.extend(Date.prototype, {
	toJSON: function() {
	return '"' + this.getUTCFullYear() + '-' +
		(this.getUTCMonth() + 1).toPaddedString(2) + '-' +
		this.getUTCDate().toPaddedString(2) + 'T' +
		this.getUTCHours().toPaddedString(2) + ':' +
		this.getUTCMinutes().toPaddedString(2) + ':' +
		this.getUTCSeconds().toPaddedString(2) + 'Z"';
	},	//	toJSON
	
	dateAdd: function(interval, n, cal) {
		var dt = new Date(this);
		if (!interval || !n) return;
		var s = 1, m = 1, h = 1, dd = 1, w = 1, i = interval;
		
		//	if the user wants workdays, but didn't provide a calendar, create a generic calendar
		//if (i == "workday" || i == "w") {
			if (!cal) {
				cal = new Object();
				cal.isHoliday = function () { return false; };
			}
		//}
		
		//	if the calendar doesn't have an isHoliday() method, create a generic one
		if (typeof cal.isHoliday == "undefined") {
			cal.isHoliday = function () { return false; };
		}
		
		if (i == "month" || i == "m" || i == "quarter" || i == "q" || i == "year" || i == "y"){
			dt = new Date(dt);
			if (i == "month" || i == "m") dt.setMonth(dt.getMonth() + n);
			if (i == "quarter" || i == "q") dt.setMonth(dt.getMonth() + (n * 3));
			if (i == "year" || i == "y") dt.setFullYear(dt.getFullYear() + n);		
		}
		else if (i == "second" || i == "s" || i == "minute" || i == "n" || i == "hour" || i == "h" || i == "day" || i == "d" || i == "workday" || i == "w" || i == "week" || i == "ww") {
			dt = Date.parse(dt);
			if (isNaN(dt)) return;
			if (i == "second" || i == "s") s = n;
			if (i == "minute" || i == "n") {s = 60; m = n}
			if (i == "hour" || i == "h") {s = 60; m = 60; h = n};
			if (i == "day" || i == "d") {s = 60; m = 60; h = 24; dd = n};			//	doesn't take daylight saving into account
			if (i == "week" || i == "ww") {s = 60; m = 60; h = 24; dd = 7; w = n};	//	doesn't take daylight saving into account
			dt += (((((1000 * s) * m) * h) * dd) * w);								//	adds milliseconds to date 1, so it may be an hour off if days or weeks are used
			dt = new Date(dt);
			if (i == "workday" || i == "w") {
				s = 60;
				m = 60;
				h = 24;
				if (n > 0) {
					dtTemp = new Date(dt);
					for (var v = 1; v <= n; v++) {
						dtTemp.setDate(dtTemp.getDate() + 1);
						if (dtTemp.getDay() % 6 == 0 || cal.isHoliday(dtTemp)) v--;
					}
				}
				else {
					dtTemp = new Date(dt);
					for (var v = 0; v >= n; v--) {
						if (dtTemp.getDay() % 6 == 0 || cal.isHoliday(dtTemp)) v++;
						dtTemp.setDate(dtTemp.getDate() - 1);
					}
				}
				dt = new Date(dtTemp);
			}
		}
		return dt;
	},	//	dateAdd
	
	dateDiff: function(interval, dt2, firstdow, cal){
		//	return the number of intervals crossed
		//	11:01 to 11:59 is 0 hours
		//	10:59 to 11:01 is 1 hour
		//	When computing for days, if hours are used, the utc offset for each 
		//			date must be used, otherwise 1/1/2009 to 7/1/2009 returns one 
		//			hour short because we set our clocks an hour ahead in the 
		//			spring.  This may equate to losing a day, week, or month in 
		//			the calculation.
		
		var dt1 = new Date(this);
		if (!interval || !dt1 || !dt2) return;
		var v, s = 1, m = 1, h = 1, dd = 1, i = interval;
		
		//	if the user wants workdays, but didn't provide a calendar, create a generic calendar
		//if (i == "workday" || i == "w") {
			if (!cal) {
				cal = new Object();
				cal.isHoliday = function () { return false; };
			}
		//}
		
		//	if the calendar doesn't have an isHoliday() method, create a generic one
		if (typeof cal.isHoliday == "undefined") {
			cal.isHoliday = function () { return false; };
		}
		
		//	default firstdow to Sunday
		if (!firstdow || isNaN(firstdow)) {
			firstdow = 0;
		}
		firstdow *= 1.0;
		
		//Console.Writeln("ok");
		//if(i == "month" || i == "m" || i == "quarter" || i == "q" || i == "year" || i == "y"){
			dt1 = new Date(dt1);
			dt2 = new Date(dt2);
			years = dt2.getFullYear() - dt1.getFullYear();
			switch (i) {
				case "year" :
				case "y" :
					v = years;
					break;
				case "quarter" :
				case "q" :
					v = Math.floor(dt2.getMonth() / 3) - Math.floor(dt1.getMonth() / 3);
					if (years != 0) v += (years * 4);
					break;
				case "month" :
				case "m" :
					v = (dt2.getMonth() + 1) - (dt1.getMonth() + 1);
					if (years != 0) v += (years * 12);
					break;
				case "week" :
				case "w" :
					dt1.setDate(dt1.getDate() - (dt1.getDay() - firstdow) - (dt1.getDay() < firstdow ? 7 : 0));
					dt2.setDate(dt2.getDate() - (dt2.getDay() - firstdow) - (dt2.getDay() < firstdow ? 7 : 0));
					v = dt1.dateDiff("d", dt2) / 7;
					break;
				case "workday" :
				case "wd" :
					v = 0;
					if (dt1 == dt2) {
						v++;
					}
					else if (dt1 < dt2) {
						for (var dtTemp = new Date(dt1); dtTemp <= dt2; ) {
							//	don't count weekends or holidays
							//	Since sunday.getDay() = 0 and saturday.getDay() = 6, date.getDay() % 6 = 0 for both
							if (dtTemp.getDay() % 6 != 0 && !cal.isHoliday(dtTemp)) v++;
							dtTemp.setDate(dtTemp.getDate() + 1);
						}
					}
					else {
						for (var dtTemp = new Date(dt2); dtTemp <= dt1; ) {
							if (dtTemp.getDay() % 6 != 0 && !cal.isHoliday(dtTemp)) v--;
							dtTemp.setDate(dtTemp.getDate() + 1);
						}
					}
					v--;
					break;
				case "day" :
				case "d" :
					//	adjust for a difference caused by daylight savings
					dt2.setHours(dt2.getHours() + ((dt1.getTimezoneOffset() - dt2.getTimezoneOffset()) / 60));
					dt1 = Date.parse(dt1);
					dt2 = Date.parse(dt2);
					//	truncate the date value to the previous hour break
					dt1 -= (dt1 % (1000 * 60 * 60));
					dt2 -= (dt2 % (1000 * 60 * 60));
					v = (dt2 - dt1) / (1000 * 60 * 60 * 24);
					break;
				case "hour" :
				case "h" :
					dt1 = Date.parse(dt1);
					dt2 = Date.parse(dt2);
					//	truncate the date value to the previous hour break
					dt1 -= (dt1 % (1000 * 60 * 60));
					dt2 -= (dt2 % (1000 * 60 * 60));
					v = (dt2 - dt1) / (1000 * 60 * 60);
					break;
				case "minute" :
				case "n" :
					dt1 = Date.parse(dt1);
					dt2 = Date.parse(dt2);
					//	truncate the date value to the previous minute break
					dt1 -= (dt1 % (1000 * 60));
					dt2 -= (dt2 % (1000 * 60));
					v = (dt2 - dt1) / (1000 * 60);
					break;
				case "second" :
				case "s" :
					dt1 = Date.parse(dt1);
					dt2 = Date.parse(dt2);
					//	truncate the date value to the previous second break
					dt1 -= (dt1 % 1000);
					dt2 -= (dt2 % 1000);
					v = (dt2 - dt1) / 1000;
					break;
			}
		//}
		return v;
	},	//	dateDiff
	
	format: function (DateFormat) {
	/*
		Object Method:	Date.format()
		
		Type:		JavaScript 
		Purpose:	Provides a method for formatting dates according to 
					a specific date format pattern string.
		Inputs:		object			Required	a Date object
					NumberFormat	Required	the string pattern defining how to format the number
												eg. "mm/dd/yyyy"
		
		Returns:	A string containing the formatted date.
		
		Revision History
		Date		Developer	Description
	 
	*/
		if (!this.isDate()) return "Invalid date";
		//if (!this.valueOf())
		//	return " ";
		if (DateFormat == undefined)
			return(this.toLocaleDateString());
		
		var d = this;
		
		//DateFormat = DateFormat.toLowerCase();
		
		var s = DateFormat.replace(/(yyyy|yy|mmmm|mmm|mm|m|dddd|ddd|dd|dth|d|hh|h|nn|n|ss|s|a\/p|am\/pm)/gi,
			function($1) {
				switch ($1.toLowerCase()) {
					case "am":  
					case "pm":  return $1;
					case "yyyy": return d.getFullYear();
					case "yy": return d.getFullYear().toString().substr(d.getFullYear().toString().length - 2);
					case "mmmm": return Date.MonthName[d.getMonth()];
					case "mmm":  return Date.MonthName[d.getMonth()].substr(0, 3);
					case "mm":   return (d.getMonth() + 1).toPaddedString(2);
					case "m":   return (d.getMonth() + 1);
					case "dddd": return Date.WeekdayName[d.getDay()];
					case "ddd":  return Date.WeekdayName[d.getDay()].substr(0, 3);
					case "dd":   return d.getDate().toPaddedString(2);
					case "dth":   return d.getDate().ord();
					case "d":   return d.getDate();
					case "hh":   
						h = d.getHours() % 24;
						if (DateFormat.search(/am\/pm/i) != -1 || DateFormat.search(/a\/p/i) != -1) {
							h %= 12;
							h = (h == 0) ? 12 : h;
						}
						return h.toPaddedString(2);
					case "h":   
						h = d.getHours() % 24;
						if (DateFormat.search(/am\/pm/i) != -1 || DateFormat.search(/a\/p/i) != -1) {
							h %= 12;
							h = (h == 0) ? 12 : h;
						}
						return h;
					case "nn":   return d.getMinutes().toPaddedString(2);
					case "n":   return d.getMinutes();
					case "ss":   return d.getSeconds().toPaddedString(2);
					case "s":   return d.getSeconds();
					case "a/p":  return $1 == $1.toLowerCase() ? (d.getHours() < 12 ? "a" : "p") : (d.getHours() < 12 ? "a" : "p").toUpperCase();
					case "am/pm":  return $1 == $1.toLowerCase() ? (d.getHours() < 12 ? "am" : "pm") : (d.getHours() < 12 ? "am" : "pm").toUpperCase();
					default:  return $1;
				}
			}
		);
		
		return s;
	},	//	format
	
	getLocalFromUTC: function () {
	/*
		Object Method:	Date.getLocalFromUTC()
		
		Type:		JavaScript 
		Purpose:	Convert the UTC time to the local time.
		Inputs:		object			Required	a Date object
		
		Returns:	A date object
		
		Revision History
		Date		Developer	Description
		7/16/2010	Doug Pulse	Original
	*/
		var d = new Date(this);
		d.setHours(d.getHours() - (d.getTimezoneOffset() / 60));
		
		return d;
	},	//	getLocalFromUTC
	
	isDate: function () {
		return Object.isDate(this);
	}	//	isDate
});

    return {
        loaded: function () {
            return true;
        }
    };
});