# Software REST API

Swagger-based documentation: http://<cognos_analytics_server>:<port>/api/api-docs

## WARNING

This code was developed to run on Windows 10, Window Server 2012 (or higher), PowerShell 7, SQL Server, Cognos Analytics 11.2.4, my environment, etc.  Basically, your mileage may vary.

## Content

#### fn.ps1

A collection of functions useful for working with the Cognos Analytics REST API.

#### ModuleBusinessNames.ps1

Leverage your data catalog to automatically populate a data module with human-readable names and descriptions for tables (query subjects) and columns (query items).

Assumes you are using Windows, PowerShell 7, SQL Server, Cognos Analytics 11.2.4, maybe other stuff.  Basically, your mileage may vary.

#### REST API Example.ps1

An example showing how to leverage the common functions found in fn.ps1.

Requires fn.ps1

#### getCSV.ps1

For one report, output all CSV outputs that are stored in Cognos.  Requires the CSV output to already be saved in a report version.

Requires fn.ps1

