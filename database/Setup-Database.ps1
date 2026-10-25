[CmdletBinding()]
param(
    [string] $Server = 'localhost,1433',
    [string] $Username = 'sa',
    [System.Management.Automation.PSCredential] $Credential
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'SqlServer.ps1')
if ($null -eq $Credential) { $Credential = Get-MovieHubSqlCredential -Username $Username }
Invoke-MovieHubSqlFile -Path (Join-Path $PSScriptRoot '000-create-database.sql') `
    -Database 'master' -Server $Server -Credential $Credential
Invoke-MovieHubSqlFile -Path (Join-Path $PSScriptRoot '001-schema.sql') `
    -Database 'MovieHub' -Server $Server -Credential $Credential
