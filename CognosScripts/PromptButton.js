define( function() {
	"use strict";
	
	var log = function (label, message) {
		console.log("    ****    " + label + " : " + message);
	};
	
	
	function Button() {
	};
	
	
	Button.prototype.initialize = function( oControlHost, fnDoneInitializing ) {
		log("Button", "Control.initialize" );
		
		/*
		Configuration:
		{
			"ButtonType": "Finish",
			"ButtonLabel": "Finish",
			"RequiredPrompts": 	//	this is [ [a and b] or [a and c] ]
			[
				["WorkOrder", "Bien"], 
				["WorkOrder", "fy"]
			], 
			"RequiredPromptCount": 2,
			"HiddenPrompt": "MyHiddenPrompt",
			"ValidationFailureAlert": "validation failed"
		}
		*/
		
		/*
			Using RequiredPrompts or RequiredPromptCount probably only makes
			sense with a ButtonType of Finish or Next.
			
			Using HiddenPrompt is for when the page may already have all 
			required prompts set, but you want to allow autosubmit to control 
			other prompting and not to "finish" prompting.
			The prompt used for HiddenPrompt should be a Text Box Prompt.
		*/
		
		this.controlHost = oControlHost;
		this.oConfig = this.controlHost.configuration;
		this.page = this.controlHost.page;
		this.Prompts = this.page.getAllPromptControls();
		this.ButtonType = ( this.oConfig && this.oConfig.ButtonType ) ? this.oConfig.ButtonType : "Finish";
		this.ButtonLabel = ( this.oConfig && this.oConfig.ButtonLabel ) ? this.oConfig.ButtonLabel : this.ButtonType;
		this.failureAlert = ( this.oConfig && this.oConfig.ValidationFailureAlert ) ? this.oConfig.ValidationFailureAlert : null;
		
		this.RequiredPromptsValidator = function (arr) {
			//[
			//	["WorkOrder", "Bien"], 
			//	["WorkOrder", "fy"]
			//]
			var valid = false;
			var v;			//	prompt values
			
			for (var i = 0; i < arr.length; i++) {
				var m = 0;
				for (var j = 0; j < arr[i].length; j++) {
					if (this.page.getControlByName(arr[i][j])) {
						v = this.page.getControlByName(arr[i][j]).getValues();
						//	A single-select textbox prompt is a special case.
						//	If it is empty, getValues() returns an array with one element:
						//		[{"use":null,"display":null}]
						if (v.length == 1 && v[0].use == null && v[0].display == null) {
						}
						else if (v.length > 0) {
							m++;
						}
					}
				}
				if (m == j) {
					valid = true;
					break;
				}
			}
			return valid;
		};
		
		this.RequiredPromptCountValidator = function (n) {
			var m = 0;		//	How many prompts have values?
			var v;			//	prompt values
			
			if (n < 1) return true;		//	No prompts are required.  Why use this feature?
			
			for (var i = 0; i < this.Prompts.length && m < n; i++) {
				if (this.Prompts[i].name.substr(0, 4) == 'oper') {
					//	this is an operator selector
					//	don't count this in fulfilling a minimum number of parameters
				}
				else {
					v = this.Prompts[i].getValues();
					//	A single-select textbox prompt is a special case.
					//	If it is empty, getValues() returns an array with one element:
					//		[{"use":null,"display":null}]
					if (v.length == 1 && v[0].use == null && v[0].display == null) {
					}
					else if (v.length > 0) {
						m++;
					}
				}
			}
			
			return m >= n;
		};
		
		this.CompletePromptInit = function (s) {
			var done = false;
			var p;
			
			log("CompletePromptInit", s);
			
			p = this.page.getControlByName(s)
			
			if (p) {
				p.setValues([{"use": undefined, "display": undefined}]);
				done = true;
				log("CompletePromptInit", "success");
			}
			else {
				done = false;
				log("CompletePromptInit", "failure");
			}
			
			return done;
		};
		
		this.CompletePrompt = function (s) {
			var done = false;
			var p;
			
			log("CompletePrompt", s);
			
			p = this.page.getControlByName(s)
			
			if (p) {
				p.setValues([{"use": "a", "display": "a"}]);
				done = true;
				log("CompletePrompt", "success");
			}
			else {
				done = false;
				log("CompletePrompt", "failure");
			}
			
			return done;
		};
		
		this.TakeAction = function () {
			var i = 0;
			var msg = "";
			
			if (this.oConfig && this.oConfig.RequiredPrompts) {
				if (this.RequiredPromptsValidator(this.oConfig.RequiredPrompts)) i++;
				else msg += "\r\n    The required parameters were not specified.";
			}
			else {
				i++;
			}
			
			if (this.oConfig && this.oConfig.RequiredPromptCount) {
				if (this.RequiredPromptCountValidator(this.oConfig.RequiredPromptCount)) i++;
				else msg += "\r\n    Not enough parameters were specified.";
			}
			else {
				i++;
			}
			
			if (this.oConfig && this.oConfig.HiddenPrompt) {
				if (this.CompletePrompt(this.oConfig.HiddenPrompt)) i++;
				else msg += "\r\n    Prompt named " + this.oConfig.HiddenPrompt + " was not found or could not be set.";
			}
			else {
				i++;
			}
			
			if (i == 3) {
				//	passed validation.  take action
				switch (this.ButtonType.toLowerCase()) {
					case "finish":
						this.controlHost.finish()
						break;
					case "next":
						this.controlHost.next()
						break;
					case "back":
						this.controlHost.back()
						break;
					case "reprompt":
						this.controlHost.reprompt()
						break;
					case "cancel":
						this.controlHost.cancel()
						break;
					default:
						//	error
				}
			}
			else {
				//	failed validation.  do nothing?  alert the user?  write to the console?
				log("Prompt Validation Failure", "Unable to use the " + this.ButtonType.toUpperCase() + " feature because prompt validation failed." + msg);
				if (this.failureAlert) alert(this.failureAlert);
			}
		};
		
		if (this.oConfig && this.oConfig.HiddenPrompt) {
			if (this.CompletePromptInit(this.oConfig.HiddenPrompt)) {
			}
			else {
				log("Prompt Validation Failure", "Unable to initialize.\r\n    Prompt named " + this.oConfig.HiddenPrompt + " was not found or could not be set.");
			}
		}
		
		fnDoneInitializing();
	};
	
	Button.prototype.draw = function( oControlHost ) {
		log("Button", "Control.draw" );
			
		//var d = document.createElement("div");
		//	d.className = "clsPromptComponent";
		//	d.setAttribute("pt", "btn");
		var b = document.createElement("button");
			b.className = "bp";
			b.type = "button";
			b.onmouseover = function () {this.className = 'bp bph'};
			b.onmouseout = function () {this.className = 'bp'};
			b.onclick = this.TakeAction.bind(this);
			b.innerHTML = this.ButtonLabel;
		oControlHost.container.appendChild(b);
		//d.appendChild(b);
		//oControlHost.container.appendChild(d);
	};
	
	return Button;
});