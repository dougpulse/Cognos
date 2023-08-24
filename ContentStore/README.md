# Cognos Content Store Database
Cognos stores most content in this database.

I use Microsoft SQL Server.  Your mileage may vary.

Hacking the Cognos Content Store database is not recommended.  The correct, supported way to automate Cognos management tasks is by using the Cognos SDK.

### ContentStore.txt

Listing and description of tables in the Content Store database.  Found on Cognoise.com.  Comments updated as new insights are realized.
  
### ContentStoreCMIDSearch.sql

Listing and description of tables in the Content Store database.  Found on Cognoise.com.  Comments updated as new insights are realized.
Limited and formatted specifically for searching for a specific CMID.
  
### CognosScheduleEmailRecipients.sql

Lists email recipients for schedules.
  
### LocateSchedules.sql

Outputs the path to each schedule.
  
### OutputSpecs.sql

Output specifications for reports, dashboards, and data sets within Team Content with the folder structure seen in Cognos.  This can be used as part of a routine to write to the file system.
  
### SpecBackup (folder)

Output specifications for reports, dashboards, and data sets to the file system and push them to a source control repository.

### BrokenShortcuts.sql

Find broken shortcuts and report views.

### OwnedObjects.sql

See which objects a user owns.

### PackageReference.sql

Identifies data containers (packages, data modules, etc.) and which presentation objects (reports, dashboards, etc.) use them.  
Also identifies data containers that are not used.
Identifies where a data module uses a dataset that is populated from a data module that uses a dataset that uses a package (etc.) 
and attributes the usage (presentation object) to the parent data container.
Whether or not the presentation objects have been used is a different question.  This routine considers only object references, not usage stats from the Audit database.

### ModuleAndModelSpecs.SQL

Initially intended to allow a system-wide search for packages and models that use a specific data source.

## Permissions

### SQL-Only

#### PermissionsPerUser.sql

Find everywhere that a user (or group) from Active Directory is defined in object permissions in Cognos.

For objects that inherit permissions, POLICIES is NULL.  These are not identified by this query.

This query processes the CMPOLICIES.POLICIES value for all objects in the Content Store using two, nested functions, then performs the search (filter) on the results.  It can take a very long time to run.

Requires udf_CognosPermissions.sql and ADSI.sql.

#### udf_CognosPermissions.sql

Converts CMPOLICIES.POLICIES (image) to a human-readable string.

Requires udf_ConvertFromBase10.sql

#### udf_ConvertFromBase10.sql

Converts a number in base 10 to a string (varchar(255)) containing the number in another number base.

Used by udf_CognosPermissions to convert 64-bit encoded characters to binary.

#### ADSI.sql

Sets up the linked server to query Active Directory.

From https://www.mssqltips.com/sqlservertip/2580/querying-active-directory-data-from-sql-server/

Make sure you change the @rmtuser and @rmtpassword variables to a login and password that has access to your Active Directory.

### SQL and PowerShell

If you can't create a linked server and a user-defined function, 
maybe you'll have the ability to look up the information using PowerShell.

#### RoleGroupMembership.ps1

Lists members of all Cognos roles.

#### ObjectPermissions.ps1

Lists what permissions users and groups have to each Cognos object within Team Content (CMID=2).  
Takes about 5 minutes to run.  Our Content Store has about 190,000 rows in CMOBJECTS with about 7,300 objects within the scope of this script.

#### ObjectCapabilities.ps1

Lists what permissions (grant or deny) users and groups have to each capability for each Cognos object within Team Content (CMID=2).  
Takes about 5 minutes to run.  Our Content Store has about 190,000 rows in CMOBJECTS with about 1,250 objects within the scope of this script.
