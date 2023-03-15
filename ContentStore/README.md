# Cognos Content Store Database
Cognos stores most content in this database.

I use Microsoft SQL Server.  Your mileage may vary.

Hacking the Cognos Content Store database is not recommended.  The correct, supported way to automate Cognos management tasks is by using the Cognos SDK.

## ContentStore.txt ##

Listing and description of tables in the Content Store database.  Found on Cognoise.com.  Comments updated as new insights are realized.
  
## CognosScheduleEmailRecipients.sql ##

Lists email recipients for schedules.
  
## LocateSchedules.sql ##

Outputs the path to each schedule.
  
## OutputSpecs.sql ##

Output specifications for reports, dashboards, and data sets within Team Content with the folder structure seen in Cognos.  This can be used as part of a routine to write to the file system.
  
## SpecBackup (folder) ##

Output specifications for reports, dashboards, and data sets to the file system and push them to a source control repository.

## BrokenShortcuts.sql ##

Find broken shortcuts and report views.


## PermissionsPerUser.sql ##

Find everywhere that a user (or group) from Active Directory is defined in object permissions in Cognos.

For objects that inherit permissions, POLICIES is NULL.  These are not identified by this query.

This query processes the CMPOLICIES.POLICIES value for all objects in the Content Store using two, nested functions, then performs the search (filter) on the results.  It can take a very long time to run.

Requires udf_CognosPermissions.sql.

## udf_CognosPermissions.sql ##

Converts CMPOLICIES.POLICIES (image) to a human-readable string.

Requires udf_ConvertFromBase10.sql

## udf_ConvertFromBase10.sql ##

Converts a number in base 10 to a string (varchar(255)) containing the number in another number base.

Used by udf_CognosPermissions to convert 64-bit encoded characters to binary.