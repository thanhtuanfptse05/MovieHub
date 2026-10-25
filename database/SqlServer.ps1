# Deployment/test helper only. Application persistence remains in JPA.
Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Data

function Get-MovieHubSqlCredential {
    param([string] $Username = 'sa')
    if ($env:DB_PASSWORD) {
        $secret = ConvertTo-SecureString $env:DB_PASSWORD -AsPlainText -Force
    } else {
        $secret = Read-Host "SQL Server password for $Username" -AsSecureString
    }
    return [System.Management.Automation.PSCredential]::new($Username, $secret)
}

function Invoke-MovieHubSqlFile {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Database,
        [Parameter(Mandatory = $true)][System.Management.Automation.PSCredential] $Credential,
        [string] $Server = 'localhost,1433'
    )
    $builder = [System.Data.SqlClient.SqlConnectionStringBuilder]::new()
    $builder['Data Source'] = $Server
    $builder['Initial Catalog'] = $Database
    $builder['Encrypt'] = $true
    $builder['TrustServerCertificate'] = $true
    $builder['Connect Timeout'] = 10
    $builder['Application Name'] = 'MovieHubDatabaseSetup'
    $secret = $Credential.Password.Copy()
    $secret.MakeReadOnly()
    $sqlCredential = [System.Data.SqlClient.SqlCredential]::new($Credential.UserName, $secret)
    $connection = [System.Data.SqlClient.SqlConnection]::new($builder.ConnectionString, $sqlCredential)
    try {
        $connection.Open()
        $sql = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
        $batches = [regex]::Split($sql, '(?m)^\s*GO\s*(?:--[^\r\n]*)?\r?$')
        foreach ($batch in $batches) {
            if ([string]::IsNullOrWhiteSpace($batch)) { continue }
            $command = $connection.CreateCommand()
            $command.CommandText = $batch
            $command.CommandTimeout = 60
            $adapter = [System.Data.SqlClient.SqlDataAdapter]::new($command)
            $data = [System.Data.DataSet]::new()
            try {
                [void] $adapter.Fill($data)
                foreach ($table in $data.Tables) {
                    foreach ($row in $table.Rows) {
                        $record = [ordered]@{}
                        foreach ($column in $table.Columns) {
                            $record[$column.ColumnName] = $row[$column]
                        }
                        [pscustomobject] $record
                    }
                }
            } finally {
                $data.Dispose()
                $adapter.Dispose()
                $command.Dispose()
            }
        }
    } finally {
        $connection.Dispose()
        $secret.Dispose()
    }
}
