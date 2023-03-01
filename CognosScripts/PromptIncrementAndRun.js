define( function() {
	"use strict";
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	};
	
	function Button() {
	};
	
	
	Button.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		/*
		Configuration:
		{
			"ButtonLabel": "Increment Day Number",
			"PromptName": "DayNumberPrompt"
		}
		*/
		
		this.controlHost = oControlHost;
		this.oConfig = this.controlHost.configuration;
		this.page = this.controlHost.page;
		this.PromptName = ( this.oConfig && this.oConfig.PromptName ) ? this.oConfig.PromptName : "Prompt1";
		this.ButtonLabel = ( this.oConfig && this.oConfig.ButtonLabel ) ? this.oConfig.ButtonLabel : "Finish";
		this.Prompt = this.page.getControlByName(this.PromptName);
		this.DayNum = this.Prompt.getValues();
		//	You may want to verify that DayNum is a number.
		//	Here I just check to see if it is blank and set a default value if it is.
		if (typeof this.DayNum[0].use == "undefined") this.DayNum = [{"use": "1", "display": "1"}];
		
		this.TakeAction = function () {
			this.DayNum[0].use = ((this.DayNum[0].use * 1.0) + 1).toString();
			this.DayNum[0].display = ((this.DayNum[0].display * 1.0) + 1).toString();
			this.Prompt.setValues(this.DayNum);
			this.controlHost.finish();
		};
		
		fnDoneInitializing();
	};
	
	Button.prototype.draw = function( oControlHost ) {
		var b = document.createElement("button");
			b.className = "bp";
			b.type = "button";
			b.onmouseover = function () {this.className = 'bp bph'};
			b.onmouseout = function () {this.className = 'bp'};
			b.onclick = this.TakeAction.bind(this);
			b.innerHTML = this.ButtonLabel;
		oControlHost.container.appendChild(b);
	};
	
	return Button;
});
