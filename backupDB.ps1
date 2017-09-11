param(  
    $serverName,
	$databaseName,
    $backupDirectory
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $serverName
$dbs = $server.Databases
$database = $dbs[$databaseName]

$dbName = $database.Name

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
