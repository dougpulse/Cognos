define( ["/CognosScripts/ol-debug.js", "https://cdnjs.cloudflare.com/ajax/libs/proj4js/2.3.15/proj4.js", "/CognosScripts/mapPopupOpenLayers.js", "jquery"], function( ol, proj4, Popup, $ ) {
"use strict";

	Array.prototype.contains = function (ValueToFind) {
		for (var a in this) {
			if (this[a] == ValueToFind) return true;
		}
		for (var i = 0; i < this.length; i++) {
			if (this[i] == ValueToFind) return true;
		}
		return false;
	}
	
	function olMap(){};
	
	olMap.prototype.initialize = function ( oControlHost, fnDoneInitializing ) {
		oControlHost.loadingText = "Loading data...";
		var o = oControlHost.configuration;
		
		/*
		//	sample configuration object
		{
			"Fill": {
				"color": [
					192,
					0,
					0,
					0.1
				]
			},
			"Stroke": {
				"color": [
					192,
					0,
					0
				],
				"width": 1.25
			},
			"NoDataMessage": "No data available.",
			"EPSGCode": "2927",
			"baseMap": {
				"type": "ArcGISOnline",
				"name": "WSDOT Base Map",
				"url": "http://data.wsdot.wa.gov/arcgis/rest/services/Shared/WebBaseMapWebMercator/MapServer"
			},
			"Popup": {
				"event": "singleclick"
			},
			"DataLayer": {
				"url": "http://hqolymgis27d:6080/arcgis/rest/services/PlannedProjects/PlannedProjects/FeatureServer/",
				"layer": "1",
				"id": "PIN",
				"outFields": ["PIN","Project_Title","Sub_Program","StateRouteNumber"]
			}
		}
		*/
		
		//	===		Load the OpenLayers style sheet		===
		var link = document.createElement("link");
		link.type = "text/css";
		link.rel = "stylesheet";
		link.href = "/CognosScripts/ol.css";
		document.getElementsByTagName("head")[0].appendChild(link);
		
		
		
		
		//	project
		
		//	use EPSG:2927 NAD83(HARN) / Washington South (ftUS) for X/Y
		//	use EPSG:3857 WGS84 Web Mercator (Auxiliary Sphere) for X/Y
		//	use EPSG:4326 WGS84  for lon/lat
		//	If no EPSG code is provided, default to EPSG:2927.
		var EPSGCode = ( o && o.EPSGCode ) ? o.EPSGCode : "2927";
		
		/*===   This should be in its own module (EPSGInfo.js).   ===*/
		function getEPSGInfo(code) {
			var sPage = "https://epsg.io/?format=json&q=" + code;
			
			var xmlReq = new XMLHttpRequest();
			xmlReq.open("GET", sPage, false);
			xmlReq.send(null);
			var xmlResp = xmlReq.responseText;
			//console.writeln(xmlResp);
			return JSON.parse(xmlResp).results[0];
		}
		/*===========================================================*/
		//var epsg = EPSGInfo(EPSGCode);
		var epsg = getEPSGInfo(EPSGCode);
		
		this.m_longCode = "EPSG:" + EPSGCode;
		
		proj4.defs(this.m_longCode, epsg.proj4);
		
		
		//	set fill and stroke
		this.m_fill = ( o && o.Fill ) ? o.Fill : {color: [192,0,0,.1]};
		this.m_stroke = ( o && o.Stroke ) ? o.Stroke : {color: [192,0,0], width: 1.25};
		
		
		//	set the "no data" message
		this.m_msg = o && o.NoDataMessage ? o.NoDataMessage : "No data available"
		
		
		//	use the WSDOT Base Map from ArcGISOnline as the default
		this.m_baseMap = o && o.baseMap ? o.baseMap : {"type": "ArcGISOnline", "url": "http://data.wsdot.wa.gov/arcgis/rest/services/Shared/WebBaseMapWebMercator/MapServer"};
		this.m_baseMap.url = this.m_baseMap.url ? this.m_baseMap.url : "";
		
		var bInit = true;
		
		if (o && o.DataLayer) {
			if (o.DataLayer.url && o.DataLayer.layer && o.DataLayer.id) {
				this.m_datalayer = o.DataLayer;
			}
			else {
				alert("A data layer requires a url, a layer and an id.");
				bInit = false;
			}
		}
		
		if (bInit) fnDoneInitializing();
	}
	
	olMap.prototype.draw = function( oControlHost )
	{
		var o = oControlHost.configuration;
		
		
		if (this.m_FeatureCollection.length || this.m_datalayer) {
			ol.proj.setProj4(proj4);
			
			var fill = new ol.style.Fill(this.m_fill);
			
			var stroke = new ol.style.Stroke(this.m_stroke);
			
			var FeatureStyle = {
				image: new ol.style.Circle({
					fill: fill,
					stroke: stroke,
					radius: 3
				}), 
				fill: fill,
				stroke: stroke
			};
			
			var style = new ol.style.Style(FeatureStyle);
			
			
			//	create features from data
			var myFeatures = this.m_FeatureCollection;
			
			
			//	create layers
			var baseLayer;
			if (this.m_baseMap.type == "ArcGISOnline") {
				baseLayer = new ol.layer.Tile({
					source: new ol.source.TileArcGISRest({
						attributions: [
							'<a href="' + this.m_baseMap.url + '">' + (this.m_baseMap.name ? this.m_baseMap.name : this.m_baseMap.type) + '</a>'
						], 
						"url": this.m_baseMap.url
					})
				});
			}
			else if (this.m_baseMap.type == "OSM") {
				baseLayer = new ol.layer.Tile({
					source: new ol.source.OSM()
				});
			}
			else {
				//	For some reason, we reached this point without setting a base map.
				//	display something reliable
				baseLayer = new ol.layer.Tile({
					source: new ol.source.OSM()
				});
			}
			
			if (this.m_datalayer) {
				//	DataLayer URL example:
				//http://hqolymgis27d:6080/arcgis/rest/services/PlannedProjects/PlannedProjects/FeatureServer/1/query?where=PIN+in+%28%27316707T%27%2C+%27316706T%27%2C+%27316718A%27%2C%27100585Q%27%29
				//&objectIds=
				//&time=
				//&geometry=%7B%22xmin%22%3A1176500%2C%22xmax%22%3A1176700%2C%22ymin%22%3A704200%2C%22ymax%22%3A704400%7D
				//&geometryType=esriGeometryEnvelope
				//&inSR=
				//&spatialRel=esriSpatialRelIntersects
				//&relationParam=
				//&outFields=PIN%2CProject_Title%2CSub_Program%2CStateRouteNumber
				//&returnGeometry=true
				//&maxAllowableOffset=
				//&geometryPrecision=
				//&outSR=
				//&gdbVersion=
				//&returnDistinctValues=false
				//&returnIdsOnly=false
				//&returnCountOnly=false
				//&orderByFields=
				//&groupByFieldsForStatistics=
				//&outStatistics=
				//&returnZ=false
				//&returnM=false
				//&multipatchOption=
				//&f=pjson
				
				var esrijsonFormat = new ol.format.EsriJSON();
				
				var dsRowCount = this.m_dsRowCount;
				var FeatureServiceURL = this.m_datalayer.fullURL;
				
				var dataLayerSource = new ol.source.Vector({
					attributions: [
						'<a href="http://hqolymgis27d:6080/arcgis/rest/services/PlannedProjects/PlannedProjects/FeatureServer/">WSDOT Planned Projects Map</a>'
					], 
					loader: function(extent, resolution, projection) {
						//var url = this.m_datalayer.fullURL +
						var url = FeatureServiceURL + 
							'&geometry=' + encodeURIComponent(
								'{"xmin":' + extent[0].toFixed(9) + 
								',"ymin":' + extent[1].toFixed(9) + 
								',"xmax":' + extent[2].toFixed(9) + 
								',"ymax":' + extent[3].toFixed(9) + 
								',"spatialReference":{"wkid":103181}}');
						$.ajax({
							url: url, 
							dataType: 'jsonp', 
							success: function(response) {
								if (response.error) {
									alert(response.error.message + '\n' +
									response.error.details.join('\n'));
								}
								else {
									// dataProjection will be read from document
									var features = esrijsonFormat.readFeatures(response, {
										featureProjection: projection
									});
									if (features.length > 0) {
										dataLayerSource.addFeatures(features);
										console.log("Records from query:  " + dsRowCount);
										console.log("Records from feature service:  " + features.length);
										//	The alert box below is a bad idea.
										//	There should be a custom "control" on the map that displays:
										//		x records returned from the query
										//		y records returned from feature service
										//if (features.length < dsRowCount) alert("The feature service did not return as many records as your query.  Either too many records were requested, or data is missing from the feature service.");
									}
								}
							}
						});
					},
					strategy: ol.loadingstrategy.tile(ol.tilegrid.createXYZ({
						tileSize: 512
					}))
				});
			}
			if (this.m_FeatureCollection.length) {
				var dataLayerSource = new ol.source.Vector({
					features: myFeatures
				});
			}
			
			var dataLayer = new ol.layer.Vector({
				source: dataLayerSource, 
				style: style
			});
			
			
			//	create map
			//var map = new ol.Map({});
			//	if the feature data is in web mercator (lon/lat) don't set the projection
			//var v = new ol.View({projection: this.m_longCode});
			//var lg = new ol.layer.Group({layers: [baseLayer, 
			//	dataLayer]});
			//map.setView(v);
			//map.setTarget(oControlHost.container);
			//map.setLayerGroup(lg);
			
			var map = new ol.Map({
				layers: [baseLayer, dataLayer],
				target: oControlHost.container, 
				view: new ol.View({
					projection: this.m_longCode, 
					center:[1176700,704200], 
					zoom: 7
				})//, 
				//controls: ol.control.defaults({attribution: false}).extend([attribution])
			})
			
			//	zoom to the extents of the data
			if (this.m_FeatureCollection.length) {
				var extent = dataLayer.getSource().getExtent();
				map.getView().fit(extent, map.getSize());
			}
			
			var popup = new Popup();
			map.addOverlay(popup);
			
			var popupDiv = document.createElement("div");
			oControlHost.container.appendChild(popupDiv);
			
			//map.on('pointermove', function (evt) {
			//	var feat = map.forEachFeatureAtPixel(map.getPixelFromCoordinate(evt.coordinate), 
			//		function (f, l) {
			//			return f;
			//		});
			//	if (feat) {
			//		var content = "hello";
			//		popup.show(evt.coordinate, content);
			//		//popupDiv.innerHTML = "hello";
			//		//popupDiv.style.position = "relative";
			//		//popupDiv.style.top = ""
			//		//popupDiv.style.display = "inline";
			//	}
			//	else {
			//		//popupDiv.style.display = "none";
			//		popup.hide();
			//	}
			//});
			
			map.on("postcompose", function (event) {
				$(".ol-logo-only").removeClass("ol-logo-only");
			});
			
			
			if (o && o.Popup) {
				var sEvent = (	o.Popup.event && 
								typeof o.Popup.event == "string" && 
								['click', 'dblclick', 'pointermove', 'singleclick'].contains(o.Popup.event) )
								? o.Popup.event 
								: 'singleclick';
				map.on( sEvent, function(evt) {
					//var prettyCoord = ol.coordinate.toStringHDMS(ol.proj.transform(evt.coordinate, 'EPSG:3857', 'EPSG:4326'), 2);
					//popup.show(evt.coordinate, '<div><h2>Coordinates</h2><p>' + prettyCoord + '</p></div>');
					var feat = [];
					map.forEachFeatureAtPixel(map.getPixelFromCoordinate(evt.coordinate), 
						function (f, l) {
							feat.push(f);
						});
					if (feat.length) {
						var sContent = "";
						for (var j = 0; j < feat.length; j++) {
							//sContent += "<table style=\"background-color: blue\">\r\n";
							sContent += "<table style=\"background-color: white; border-collapse: collapse; margin: 2px; \">\r\n";
							//sContent += "<table>\r\n";
							var arrContent = [];
							var k = feat[j].getKeys();
							for (var i = 0; i < k.length; i++) {
								if (k[i] != "geometry") {
									sContent += "<tr><td style=\"white-space: nowrap; border: solid 1px; \">" + k[i] + "</td>";
									sContent += "<td style=\"border: solid 1px; \">" + feat[j].get(k[i]) + "</td></tr>\r\n";
								}
							}
							sContent += "</table>\r\n";
						}
						popup.show(evt.coordinate, sContent);
					}
					else {
						popup.hide();
					}
				});
				map.on( 'singleclick', function(evt) {
					var feat = [];
					map.forEachFeatureAtPixel(map.getPixelFromCoordinate(evt.coordinate), 
						function (f, l) {
							feat.push(f);
						});
					if (feat.length) {
						//do nothing
					}
					else {
						popup.hide();
					}
				});
			}
		}
		else {
			var oMsg = document.createTextNode(this.m_msg);
			oControlHost.container.appendChild(oMsg);
		}
	};
	
	olMap.prototype.setData = function( oControlHost, oDataStore )
	{
		//	Convert the data into geoJSON.
		//	SQL can return the geometry as WKT using geomColumn.STAsText().
		
		
		//var geo = {};
		//geo.type = "FeatureCollection";
		//geo.features = [];
		
		
		//this.m_oDataStore = oDataStore;
		this.m_aData = [];
		this.m_FeatureCollection = [];
		var FeatureCollection = {
			"type": "FeatureCollection", 
			"features": [], 
			"crs": {
				"type": "name",
				"properties": {
					"name": "EPSG:2927"
				}
			}
		};
		this.m_aColumnNames = oDataStore.columnNames;
		
		var iRowCount = oDataStore.rowCount;
		var tmpRecord = {};
		this.m_dsRowCount = iRowCount;
		
		
		//	Is some data being provided by a map service?
		if (this.m_datalayer) {
			var url = this.m_datalayer.url;			//	string				url defining query to feature service
			var layer = this.m_datalayer.layer		//	string				layer
			var id = this.m_datalayer.id;			//	string				name of field to use as id
			var out = this.m_datalayer.outFields ? this.m_datalayer.outFields.join(",") : "*";	//	string	names of fields to output
			
			//	Does the data store have a column matching the id in the data layer?
			if (this.m_aColumnNames.contains(id)) {
				//	yes -- id was found in DataStore
				
				//	build the url
				var idVals = [];					//	array of strings	values from oDataStore from column named the same as id
				
				for (var iRow = 0; iRow < iRowCount; iRow++) {
					idVals.push(oDataStore.getCellValue(iRow, oDataStore.getColumnIndex(id)));
				}
				
				//console.log(idVals.join("\r\n"));
				//console.log(iRowCount);
				
				//	wkid 103181 = NAD_1983_2011_StatePlane_Washington_South_FIPS_4602_Ft_US
				//	wkid 103180 = NAD_1983_2011_StatePlane_Washington_North_FIPS_4601_Ft_US
				//	wkid 103179 = NAD_1983_2011_StatePlane_Washington_South_FIPS_4602
				//	wkid 103178 = NAD_1983_2011_StatePlane_Washington_North_FIPS_4601
				var url = url + layer + "/query/?f=json&" + 
					"returnGeometry=true" + 
					"&spatialRel=esriSpatialRelIntersects" + 
					"&geometryType=esriGeometryEnvelope" + 
					"&inSR=103181" + 
					"&outFields=" + encodeURIComponent(out) +
					"&outSR=103181" + 
					"&where=" + id + " in ('" + idVals.join("','") + "')";
					//	The rest is the geometry of the view (bounding box?).  We get this at runtime, so it belongs in the draw() method
					//'&geometry=' + encodeURIComponent(
					//	'{"xmin":' + extent[0] + 
					//	',"ymin":' + extent[1] + 
					//	',"xmax":' + extent[2] + 
					//	',"ymax":' + extent[3] + 
					//	',"spatialReference":{"wkid":103181}}')
				
				this.m_datalayer.fullURL = url;
				//window.FeatureServiceURL = url;
			}
			else {
				alert("The data store must have a column matching the id in the data layer.");
			}
		}
		//	Are there columns named X and Y?
		else if (this.m_aColumnNames.contains("X") && this.m_aColumnNames.contains("Y")) {
			//	yes
			//alert("using X/Y");
			//this.m_locationType = "XY";
			
			//	Write the data store to an array
			for (var iRow = 0; iRow < iRowCount; iRow++) {
				//	create the feature object
				tmpRecord = {"type": "Feature", "geometry": {}, "properties": {}};	//	the geometry object should be first
				
				for (var c = 0; c < oDataStore.columnCount; c++) {
					if (oDataStore.columnNames[c] == "X" || oDataStore.columnNames[c] == "Y") {
						//	exclude X and Y
					}
					else if (oDataStore.columnNames[c] == "id") {
						//	if there is an id field, use it
						tmpRecord.id = oDataStore.getCellValue(iRow, c);
					}
					else {
						tmpRecord.properties[oDataStore.columnNames[c]] = oDataStore.getCellValue(iRow, c);
					}
				}
				
				//	convert X and Y to geoJSON geometry object
				tmpRecord.geometry["type"] = "Point";
				tmpRecord.geometry["coordinates"] = [oDataStore.getCellValue(iRow, oDataStore.getColumnIndex("X")), oDataStore.getCellValue(iRow, oDataStore.getColumnIndex("Y"))];
				
				//	add the feature to the features array
				FeatureCollection.features.push(tmpRecord);
			}
		}
		//	Are there columns named lon and lat?
		else if (this.m_aColumnNames.contains("lon") && this.m_aColumnNames.contains("lat")) {
			//	yes
			//alert("using lon/lat");
			//this.m_locationType = "lonlat";
			
			//	Write the data store to an array
			for (var iRow = 0; iRow < iRowCount; iRow++) {
				//	create the feature object
				tmpRecord = {"type": "Feature", "geometry": {}, "properties": {}};	//	the geometry object should be first
				
				for (var c = 0; c < oDataStore.columnCount; c++) {
					if (oDataStore.columnNames[c] == "lon" || oDataStore.columnNames[c] == "lat") {
						//	exclude lon and lat
					}
					else if (oDataStore.columnNames[c] == "id") {
						//	if there is an id field, use it
						tmpRecord.id = oDataStore.getCellValue(iRow, c);
					}
					else {
						tmpRecord.properties[oDataStore.columnNames[c]] = oDataStore.getCellValue(iRow, c);
					}
				}
				
				//	convert lon and lat to geoJSON geometry object
				tmpRecord.geometry["type"] = "Point";
				tmpRecord.geometry["coordinates"] = [oDataStore.getCellValue(iRow, oDataStore.getColumnIndex("lon")), oDataStore.getCellValue(iRow, oDataStore.getColumnIndex("lat"))];
				
				//	add the feature to the features array
				FeatureCollection.features.push(tmpRecord);
			}
		}
		else {
			//	no
			//	no geometry columns found
			alert("No geometry found.");
		}
		this.m_FeatureCollection = (new ol.format.GeoJSON()).readFeatures(FeatureCollection);
		
		//this.m_FeatureCollection = FeatureCollection;
	};
	
	return olMap;
});
