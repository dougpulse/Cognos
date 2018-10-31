# CognosScripts
This is where I put all of the JavaScript modules.  On my Cognos server, this lives at wwwroot\CognosScripts.

<dl>
  <dt>Prompts.js</dt>
  <dd>A page module that provides various ways to control prompt behaviours.</dd>

  <dt>PromptAutoFinish.js</dt>
  <dd>Custom Control module that works with Prompts.js to autofinish (autonext?) a prompt page.</dd>

  <dt>ObjectMethods.js</dt>
  <dd>A collection of additional object methods to make some scripting tasks simpler.<br />Used by Prompts.js.</dd>

  <dt>HolidayCalendar.js</dt>
  <dd>Provides a HolidayCalendar object used by some methods of the Date object that are defined in ObjectMethods.js.<br />Used by Prompt.js.</dd>

  <dt>mapOpenLayers.js</dt>
  <dd>Provides a means to present points on a map using a base map from OpenStreetMap or ArcGISOnline.</dd>

  <dt>OrderOfMethodsPageModule.js and OrderOfMethodsCustomControl.js</dt>
  <dd>Used to demonstrate when events occur in the Cognos JavaScript API.</dd>

  <dt>ParameterToText.js</dt>
  <dd>Parses the XML stored in the COGIPF_PARAMETER_VALUE_BLOB field for paramValue records and makes them human-readable for reporting.</dd>

  <dt>cleanParams.js</dt>
  <dd>Used by ParameterToText.js to return the human-readable text.</dd>

  <dt>xml2json.js</dt>
  <dd>Used by ParameterToText.js to turn the XML into a JSON string.</dd>

  <dt>json2xml.js</dt>
  <dd>Not used yet.  It's the inverse of xml2json.js.</dd>

  <dt>json.js</dt>
  <dd>Used by ParameterToText.js.  Creates a JSON object only if one does not already exist.  (for old browsers)</dd>
</dl>
