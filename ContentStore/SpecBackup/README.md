# Cognos Analytics

# Backing up reports, dashboards, and data sets from Team Content/Reports

## Introduction 
Cognos stores the specifications for reports and data sets as XML and dashboards as JSON.  It is possible to output the specs to the file system and sync them with a source control system like git.  In my case, I manually cloned the repo, then wrote these scripts to do the routine work.

I use Microsoft SQL Server and Microsoft Windows Server.  Your mileage may vary.

Hacking the Cognos Content Store database is not recommended.  The correct, supported way to automate Cognos management tasks is by using the Cognos SDK.

For supported version control, look for third-party tools like Motio CI.

I used Windows Task Scheduler to make this run once per day.

PowerShell can be used to run a query against the Content Store database and save the results to the file system. Git can help with version control so you can see changes over time and revert to the appropriate version of a report in case that's needed. HTMLTidy can clean up XML. This will make it easier to compare report versions. There are some prerequisites.


## Getting Started
1. Download and install Git for Windows. It should be at e:\install\Git-2.16.2-64-bit.exe.
1. Configure SSL for git. (see below)
1. Clone the repository that contains the report backups. It's currently at https://WSDOT@dev.azure.com/WSDOT/Business%20Intelligence%20and%20Reporting/_git/Cognos%20Reports.
1. Download HTMLTidy (tidy.exe at http://www.html-tidy.org/) into %USERPROFILE%\repos\WindowsTools.
1. Download and install these components of the Microsoft® SQL Server® 2014 Feature Pack:
   - ENU\x64\SQLSysClrTypes.msi (4,188 KB)
   - ENU\x64\SharedManagementObjects.msi (7,572 KB)
   - ENU\x64\PowerShellTools.msi (2,104 KB)
1. Create a task in the Windows Task Scheduler to run powershell -file "%USERPROFILE%\repos\ReportBackup\ReportBackup.ps1" once per day.  
	! TODO !  Hide the powershell window.

## Gotchas
This document and the current state of the source code assume that things are stored in specific locations.
  - Repo containing this code:  %USERPROFILE%\repos\ReportBackup
  - Repo containing the Cognos object specs:  %USERPROFILE%\repos\CognosReports
  - Repo containing tidy.exe:  %USERPROFILE%\repos\WindowsTools

If these locations are not correct for your environment, track down all of the references in the code and fix them.



## Files ##

### ReportBackup.ps1 ###

The wrapper.  It pulls content from the git repo to ensure we're starting with current content, runs export.ps1 to get the specs from the Content Store, then runs push.ps1 to push the new content up to the remote repo.
  
### export.ps1 ###

Exports the specs from the Content Store database to files on the local system.  For performance reasons, the full content is captured only on Sundays.  This enables git to record the deletion of content.  On other days, only changes and additions in the last three days are output.
  
### push.ps1 ###

Tidies the XML or JSON to make it easy to see differences between versions, then pushes the content to the remote repo.  Uses HTML Tidy to tidy the XML files.
  
### tidy.exe ###
Included here for convenience because I can.  The <a href="http://www.html-tidy.org/documentation/#part_license">license</a> states, "Permission is hereby granted to use, copy, modify, and distribute this source code, or portions hereof, documentation and executables, for any purpose...".<br />You may want to be sure you have the current version (<a href="http://tidy.sourceforge.net/">SourceForge</a> or <a href="https://github.com/htacg/tidy-html5">Github</a>).
