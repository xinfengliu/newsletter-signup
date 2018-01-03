# Adapted from:
# https://github.com/sixeyed/docker-windows-workshop/blob/master/part-5/db/Initialize-Database.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$sa_password,

    [Parameter(Mandatory=$false)]
    [string]$data_path,

    [Parameter(Mandatory=$true)]
    [string]$db_name,

    [Parameter(Mandatory=$false)]
    [string]$secret_path
)

# start the service
Write-Host 'Starting SQL Server'
Start-Service MSSQL`$SQLEXPRESS

# set sa password 
if ($secret_path -eq "_") {
   Write-Host "PASSWORD_PATH is not set." 
} elseif (Test-Path $secret_path) {
    $sa_password = Get-Content -Raw $secret_path
    Write-Host "Password from file: $sa_password"
} else {
    Write-Host "SA password not found at: $secret_path"
}

if ($sa_password -ne "_") {
    Write-Host 'Changing SA login credentials'
    $sqlcmd = "ALTER LOGIN sa with password='$sa_password'; ALTER LOGIN sa ENABLE;"
    Invoke-SqlCmd -Query $sqlcmd -ServerInstance ".\SQLEXPRESS" 
}

# create data directory if not exist
New-item -type Directory $data_path -force

if ( ![string]::IsNullOrEmpty($db_name)) {
    # attach database if files exist:
    $mdfPath = "$data_path\${db_name}_Data.mdf"
    $ldfPath = "$data_path\${db_name}_Log.ldf"

    if ((Test-Path $mdfPath) -eq $true) {
        $sqlcmd = "CREATE DATABASE ${db_name} ON (FILENAME = N'$mdfPath')"    
        if ((Test-Path $mdfPath) -eq $true) {
            $sqlcmd =  "$sqlcmd, (FILENAME = N'$ldfPath')"
        }
        $sqlcmd = "$sqlcmd FOR ATTACH;"
        Write-Verbose 'Data files exist - will create and attach database'
    }
    else {
        # create database using the volume location:
        $sqlcmd = 
        "IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE Name = '${db_name}') 
        CREATE DATABASE ${db_name} ON 
        PRIMARY ( NAME = N'${db_name}_Data', FILENAME = N'$mdfPath') 
        LOG ON ( NAME = N'${db_name}_Log', FILENAME = N'$ldfPath' )"    
        Write-Verbose 'Data files do not exist - will create new database'
    }
}

Invoke-Sqlcmd -Query $sqlcmd -ServerInstance ".\SQLEXPRESS"
Write-Verbose "Created/Attached $db_name database, data files at: $data_path"

Write-Verbose "Started SQL Server."

$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) { 
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message	 
    $lastCheck = Get-Date 
    Start-Sleep -Seconds 2 
}