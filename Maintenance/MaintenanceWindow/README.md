# Maintenance Window
Most Cognos users expect it to be functional during regular business hours.  But I work regular business hours.  So how do I take Cognos down to perform maintenance tasks that can't be performed while Cognos is running?  Or tasks that require me to restart the IBM Cognos service?

Windows Task Scheduler to the rescue.  
Scheduling these three tasks to run daily or weekly outside of business hours meets the need.  It can run every day, whether there is maintenance work or not.  The maintenance script is configured to only perform actions on a specific day, so it will only happen once.  Of course, you can customize it to run every day in a range of dates, or access a separate calendar to manage this.  And if you schedule it weekly, an urgent need can be accommodated by scheduling a one-time run.


<dl>
  <dt>CognosStop.ps1</dt>
  <dd>Stops the IBM Cognos service.<br />I schedule this for 1:30 a.m. Sundays.</dd>
  
  <dt>CognosMaintenance.ps1</dt>
  <dd>Performs custom maintanance actions.<br />I schedule this for 1:35 a.m. Sundays, providing enough time for the IBM Cognos service to stop before this script runs.</dd>
  
  <dt>CognosStart.ps1</dt>
  <dd>Starts the IBM Cognos service.<br />I schedule this for 3:05 a.m. Sundays.  90 minutes should be more than enough time to perform maintenance actions.</dd>
</dl>
