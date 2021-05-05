define( function() {
	"use strict";
	
	/*
	Sample Configuration:
	RequiredPrompts and RequiredPromptCount do not need to be used together.
	In this example, Country and City are optional prompts (and filters).
	Since this does not use prompt validation, requiring year is meaningless.  
	Even if the Required property is Yes, it must still be specified in the 
	configuration for the custom control.  If it is not, a system-generated 
	prompt page will appear after the user clicks on the custom prompt button.
	
	{
		"name": "FinnishButton",
		"buttonLabel": "Finish",
		"RequiredPrompts": 
		[
			["Country","Year"], 
			["City","Year"]
		], 
		"RequiredPromptCount":2
	}
	*/
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	}
	
	function customFinish(){};
	
	customFinish.prototype.draw = function( oControlHost ) {
		//log("draw", "start");
		//this.m_sName = oControlHost.configuration.name || "FinishButton";
		this.msg = "";
		
		var o = oControlHost.configuration
			, buttonLabel = o["buttonLabel"] ? o["buttonLabel"] : 'Finish'
			, el = oControlHost.container;
		
		el.innerHTML = '' + 
			'<button specname="promptButton" class="bp" type="button" id="custom_PromptFinish">' + buttonLabel + '</button>' ;
		
		document.getElementById("custom_PromptFinish").onmouseover = this.AddClass.bind (this, oControlHost, el.querySelector( "#custom_PromptFinish" ), "bph");
		document.getElementById("custom_PromptFinish").onmouseout = this.RemoveClass.bind (this, oControlHost, el.querySelector( "#custom_PromptFinish" ), "bph");
		
		document.getElementById("custom_PromptFinish").onclick = this.Finish.bind(this, oControlHost);
		//log("draw", "complete");
	};
	
	customFinish.prototype.Finish = function (oControlHost) {
		//log("Finish", "start");

		if (this.checkPrompts(oControlHost)) {
			oControlHost.finish();
		}
		else {
			alert(this.msg);
		}
	};
	
	customFinish.prototype.checkPrompts = function(oControlHost) {
		//log("checkPrompts", "start");
		var o = oControlHost.configuration;
		
		var blnGood = false;
		
		if (o.RequiredPrompts && o.RequiredPromptCount) {
			blnGood = this.RequiredPrompts(o.RequiredPrompts, oControlHost) && this.RequiredPromptCount(o.RequiredPromptCount, oControlHost);
		}
		else {
			if (o.RequiredPrompts) {
				blnGood = this.RequiredPrompts(o.RequiredPrompts, oControlHost);
			}
			if (o.RequiredPromptCount) {
				blnGood = this.RequiredPromptCount(o.RequiredPromptCount, oControlHost);
			}
		}
		
		return blnGood;
	};
	
	customFinish.prototype.RequiredPrompts = function (rp, oControlHost) {
		//log("RequiredPrompts", "start");
		var blnGood = false;
		//	check the entire set
		//	if any group is complete, we're done
		rp.forEach(function (arr) {
			//	check each group
			if (!blnGood) {
				//	reset the counter
				var rpc = 0;
				arr.forEach(function(sPromptName) {
					//log("    prompt", sPromptName);
					var oPrompt = oControlHost.page.getControlByName(sPromptName);
					if (!oPrompt) {
						alert(sPromptName + " was not found.");
					}
					else {
						//log("        prompt value", JSON.stringify(oPrompt.getValues()[0].use));
						rpc += (oPrompt.getValues()[0].use == undefined || oPrompt.getValues()[0].use == "") ? 0 : 1;
					}
				});
				//	if the counter grew to the size of the array, we're good
				//log("    array length", arr.length);
				//log("    prompt count", rpc);
				if (arr.length == rpc) blnGood = true;
			}
		});
		//log("Required Prompts", blnGood);
		if (!blnGood) this.msg = "You must enter a valid combination of parameters."
		return blnGood;
	};
	
	customFinish.prototype.RequiredPromptCount = function (rpc, oControlHost) {
		//log("RequiredPromptCount", "start");
		//log(p.name, "");
		var blnGood = false;
		var i = 0;
		var a = oControlHost.page.getAllPromptControls();
		a.forEach(function(e) {
			//log("    Prompt Validation:  Prompt" + e.name, JSON.stringify(e.getValues()));
			//log("    Prompt Validation:  Prompt" + e.name, e.getValues()[0].use == undefined);
			i += e.getValues()[0].use == undefined ? 0 : 1;
			//log("    Prompt Validation:  Prompt" + e.name, i);
		});
		//log("PromptCount", i);
		//log("RequiredPromptCount", rpc);
		blnGood = i >= rpc;
		//log("Required Prompt Count", blnGood);
		if (!blnGood) this.msg = "You must enter at least " + rpc + " parameters to proceed!";
		return blnGood;
	};
	
	customFinish.prototype.AddClass = function (oControlHost, o, c) {
		//log("AddClass", "start");
		if (this.checkPrompts(oControlHost)) {
			o.classList.add(c);
		}
	};
	
	customFinish.prototype.RemoveClass = function (oControlHost, o, c) {
		//log("RemoveClass", "start");
		o.classList.remove(c);
	};
	
	return customFinish;
});