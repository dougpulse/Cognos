# ReportSpecifications
Report samples for various purposes.  These contain the report spec xml that can be easily imported into Cognos.  If you get an error regarding version compatibility, just check the first line of your own report spec and update the version number in the sample to match your environment.


<dl>
  <dt>Scriptable Reports - Order of Methods</dt>
  <dd>Demonstrates the order in which different events occur in a page module/custom control combination.<br />Uses OrderOfMethodsPageModule.js and OrderOfMethodsCustomControl.js.</dd>
  
  <dt>Prompt Scripts</dt>
  <dd>Demonstrates some ways to employ Prompts.js.</dd>
  
  <dt>Parameter Value Automation</dt>
  <dd>How to set a parameter value automatically and invisibly.  One example of where this is helpful is to take advantage of database partitioning.  For example, the database is partitioned by year, but the prompt page should not require year.  A small, quick query can be employed to determine what years are involved based on the other parameter values, then the year or years passed to the main query to make it faster.<br />Uses Prompts.js and PromptAutoFinish.js</dd>
  
  <dt>Date Calculations</dt>
  <dd>Demonstrates using MS SQL and Cognos Macros to compute different date values.</dd>
  
  <dt>ToolTips</dt>
  <dd>Show more detail about a data value in a tooltip.</dd>
  
  <dt>VariableOperator</dt>
  <dd>Ask the user how to filter.</dd>
  
  <dt>Bursting</dt>
  <dd>A very simple example of using the bursting feature.</dd>
</dl>
