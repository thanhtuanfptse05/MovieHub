[CmdletBinding()]
param(
    [string] $Server = 'localhost,1433',
    [string] $Username = 'sa',
    [System.Management.Automation.PSCredential] $Credential
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'SqlServer.ps1')
if ($null -eq $Credential) { $Credential = Get-MovieHubSqlCredential -Username $Username }
Invoke-MovieHubSqlFile -Path (Join-Path $PSScriptRoot 'tests/schema-tests.sql') `
    -Database 'MovieHub' -Server $Server -Credential $Credential
