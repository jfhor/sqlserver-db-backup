param(  
	[Parameter(Mandatory=$true)]
	[string]$serverName,
	[Parameter(Mandatory=$true)]
	[string]$databaseName,
	[Parameter(Mandatory=$true)]
    [string]$backupDirectory
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $serverName
$dbs = $server.Databases

try {
	# test connection
	$dbs | Out-Null
} catch {
	throw $_.Exception.Message
}

$database = $dbs[$databaseName]

$dbName = $database.Name
if ([string]::IsNullOrEmpty($dbName)) {
	throw "Database not found."
}

if (-Not(Test-Path $backupDirectory)) {
	throw "Please provide a valid logging filepath."
}

$timestamp = Get-Date -format yyyyMMdd-HHmmss
$targetPath = $backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak"

$smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
$smoBackup.Action = "Database"
$smoBackup.BackupSetDescription = "Full Backup of " + $dbName
$smoBackup.BackupSetName = $dbName + " Backup"
$smoBackup.Database = $dbName
$smoBackup.MediaDescription = "Disk"
$smoBackup.Devices.AddDevice($targetPath, "File")
$smoBackup.SqlBackup($server)

Write-Host backed up $dbName ($serverName) to $targetPath
