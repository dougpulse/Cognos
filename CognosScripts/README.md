# CognosScripts
This is where I put all of the JavaScript modules.  On my Cognos server, this lives at wwwroot\CognosScripts.

## Prompts.js
A page module that provides various ways to control prompt behaviours.  
**See the comments in the code for examples for the *Configuration* object for the Custom Control Module in Cognos.**

### PromptValues
Set specific values.  
Cognos expects parameter values to be strings.
#### PromptName
The *Name* property of the prompt object.
#### PromptValue
The value(s)
#### PromptRange
The range of values
#### PromptRelative
For dates, choose values relative to today.

### PromptIndex
(not yet implemented)  
Set values based on their location in the list.
#### PromptName
The *Name* property of the prompt object.
#### PromptIndex
The zero-based index of the item in the list, or a word like "first" or "last".

### SelectAll
A list of prompt names for which all of the values in the prompt will be selected.

### AutoComplete
Automatically complete this prompt page after automatically setting prompt values.  
Works with a Custom Control using *PromptAutoFinish.js*.


## PromptAutoFinish.js
Custom Control module that works with Prompts.js to autofinish (autonext?) a prompt page.

## PromptFinish.js
Custom Control module that handles RequiredPrompts and RequiredPromptCount.  This is a different take on PromptButton.js, which may work better.

## PromptButton.js
Custom Control module to create a prompt button.  Includes prompt control method for RequiredPrompts and RequiredPromptCount.

## PromptDateDefault.js
A way to use data rather than JavaScript to choose a set of default values for a date prompt.  This is an alternative to the some of the features in Prompts.js.

## ParameterCapture.js
Captures parameter name, prompt name, and selected parameter values for presentation using ParameterDisplay.js.

## ParameterDisplay.js
For each prompt on any prompt page, displays the prompt name and selected values.

## ParamDisplay.js
For each parameter, displays the parameter name and selected values.

## ObjectMethods.js
A collection of additional object methods to make some scripting tasks simpler.<br />Used by Prompts.js.

## HolidayCalendar.js
Provides a HolidayCalendar object used by some methods of the Date object that are defined in ObjectMethods.js.<br />Used by Prompt.js.

## mapOpenLayers.js
Provides a means to present points on a map using a base map from OpenStreetMap or ArcGISOnline.

## OrderOfMethodsPageModule.js and OrderOfMethodsCustomControl.js
Used to demonstrate when events occur in the Cognos JavaScript API.

## ParameterToText.js
Parses the XML stored in the COGIPF_PARAMETER_VALUE_BLOB field for paramValue records and makes them human-readable for reporting.

## cleanParams.js
Used by ParameterToText.js to return the human-readable text.

## xml2json.js
Used by ParameterToText.js to turn the XML into a JSON string.

## json2xml.js
Not used yet.  It's the inverse of xml2json.js.

## json.js
Used by ParameterToText.js.  Creates a JSON object only if one does not already exist.  (for old browsers)
</dl>
