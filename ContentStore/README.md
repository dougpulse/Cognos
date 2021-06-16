# Cognos Content Store Database
Cognos stores most content in this database.

I use Microsoft SQL Server.  Your mileage may vary.

Hacking the Cognos Content Store database is not recommended.  The correct, supported way to automate Cognos management tasks is by using the Cognos SDK.


<dl>
  <dt>ContentStore.txt</dt>
  <dd>Listing and description of tables in the Content Store database.  Found on Cognoise.com.  Comments updated as new insights are realized.</dd>
  
  <dt>CognosScheduleEmailRecipients.sql</dt>
  <dd>Lists email recipients for schedules.</dd>
  
  <dt>LocateSchedules.sql</dt>
  <dd>Outputs the path to each schedules.</dd>
  
  <dt>OutputSpecs.sql</dt>
  <dd>Output specifications for reports, dashboards, and data sets within Team Content with the folder structure seen in Cognos.  This can be used as part of a routine to write to the file system.</dd>
  
  <dt>SpecBackup (folder)</dt>
  <dd>Output specifications for reports, dashboards, and data sets to the file system and push them to a source control repository.</dd>
</dl>
