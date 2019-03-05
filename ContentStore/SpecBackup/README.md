# Spec Backup
Cognos stores the specifications for reports and data sets as XML and dashboards as JSON.  It is possible to output the specs to the file system and sync them with a source control system like git.  In my case, I manually cloned the repo, then wrote these scripts to do the routine work.

I use Microsoft SQL Server and Microsoft Windows Server.  Your mileage may vary.

Hacking the Cognos Content Store database is not recommended.  The correct, supported way to automate Cognos management tasks is by using the Cognos SDK.

For supported version control, look for third-party tools like Motio CI.

I used Windows Task Scheduler to make this run once per day.

<dl>
  <dt>ReportBackup.ps1</dt>
  <dd>The wrapper.  It pulls content from the git repo to ensure we're starting with current content, runs export.ps1 to get the specs from the Content Store, then runs push.ps1 to push the new content up to the remote repo.</dd
  
  <dt>export.ps1</dt>
  <dd>Exports the specs from the Content Store database to files on the local system.  For performance reasons, the full content is captured only on Sundays.  This enables git to record the deletion of content.  On other days, only changes and additions in the last three days are output.</dd>
  
  <dt>push.ps1</dt>
  <dd>Tidies the XML or JSON to make it easy to see differences between versions, then pushes the content to the remote repo.  Uses HTML Tidy to tidy the XML files.</dd>
  
  <dt>tidy.exe</dt>
  <dd>Included here for convenience because I can.  The <a href="http://www.html-tidy.org/documentation/#part_license">license</a> states, "Permission is hereby granted to use, copy, modify, and distribute this source code, or portions hereof, documentation and executables, for any purpose...".<br />You may want to be sure you have the current version (<a href="http://tidy.sourceforge.net/">SourceForge</a> or <a href="https://github.com/htacg/tidy-html5">Github</a>).</dd>
</dl>
