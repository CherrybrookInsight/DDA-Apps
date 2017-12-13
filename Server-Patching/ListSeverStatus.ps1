cls
$LogFilePath = "C:\Users\dzhou\OneDrive - Dimension Data\Documents\GitHubRepo\DDA-Apps\Server-Patching\ServerCheckLog.txt"
#$ServerLit = "AUNDDPDAPT01", "AUNDDPDIIS01", "AUNDDSSDBP01", "AUNDDSSDBP03", "AUNDDSSDWP01", "AUNDDSSISP01", "AUNDDSSISP02", "AUNDDVSSQL01", "AUNDDPDIIS02" 
$WebServerLit = "AUNDDPDIIS01", "AUNDDPDIIS02" 
$ServerLit | ft -AutoSize

foreach ($S in $ServerLit)
{	
	$S | Write-Host -ForegroundColor green
	$SQLComponents = gsv "*SQL*" -ComputerName $S
	if ($SQLComponents)
	{	
	
$SQLComponents | Sort-Object Status -Descending | ft -AutoSize
		"Connecting to: "+$S | Write-Host -ForegroundColor green 
		
		$DBList = Invoke-Sqlcmd -serverinstance $S -Query "sp_helpdb"
		$DBList | Out-File $LogFilePath -append -force
		
		$DBList | ft -AutoSize


	}

}

foreach ($S1 in $WebServerLit)
{
		Invoke-Command  -ComputerName $S1 { "Connecting to: "+$S1; Import-Module WebAdministration; Get-ChildItem -path IIS:\Sites | ft PSPath, Name, State -AutoSize } | out-file "C:\Users\dzhou\OneDrive - Dimension Data\Documents\GitHubRepo\DDA-Apps\Server-Patching\WebSites.txt" -Append
	
		#Invoke-Command  -ComputerName AUNDDPDIIS02 { Import-Module WebAdministration; Get-ChildItem -path IIS:\Sites | ft -AutoSize } 
		#Invoke-Command  -ComputerName AUNDDPDIIS01 { Import-Module WebAdministration; Get-ChildItem -path IIS:\Sites  | ft -AutoSize } 

}

Start-Process	"C:\Users\dzhou\OneDrive - Dimension Data\Documents\GitHubRepo\DDA-Apps\Server-Patching\WebSites.txt"
Start-Process $LogFilePath

<#

$filepath = 'C:\Users\dzhou\OneDrive - Dimension Data\Documents\GitHubRepo\DDA-Apps\Server-Patching\ServerList-13122017.xlsx'

# Copy-SQLBulk.ps1
# This shows how to use BulkCopy in PowerShell by uploading a spreadsheet to an MSSQLServer data table.
 
#$filepath = 'my_excel_file.xls'
$excelConnection="Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$filepath;Extended Properties='Excel 12.0 Xml;HDR=YES;IMEX=1'"
#$sqlConnection='Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=my_database_name;Data Source=my_server_name;'
$sqlConnection = 'Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=DDAITADMIN;Data Source=psqlaga-al01,1433;User Id=dzhou; Password=au\dzhou; '
$excelQuery='select * from [Sheet1$]'
$tablename='temp_PATALLERGY'
 
Try{
    $conn = New-Object System.Data.OleDb.OleDbConnection($excelConnection)
    $conn.open()
    $cmd=$conn.CreateCommand()
    $cmd.CommandText=$excelQuery
    $rdr=$cmd.ExecuteReader()
   
    # create the BC object
    #$sqlbc=[System.Data.SqlClient.SqlBulkCopy]$sqlConnection
   
    $sqlbc=New-Object System.Data.SqlClient.SqlBulkCopy($sqlConnection,[System.Data.SqlClient.SqlBulkCopyOptions]::TableLock)
      #$sqlbc.EnableStreaming=$true
      $sqlbc.Batchsize=1000
      $sqlbc.BulkCopyTimeout=60
      $sqlbc.DestinationTableName=$tableName
   
    # add all columns - you can add as few  as you like.
    for($i=0; $i -lt $rdr.FieldCount;$i++){
        $fname=$rdr.GetName($i)
        Write-Host $fname -ForegroundColor green
        [void]$sqlbc.ColumnMappings.Add($fname, $fname)
    }
   
    # write all of the data to the table
    $sqlbc.WriteToServer($rdr)
}
Catch{
    Write-Host "$_" -ForegroundColor red
}
 
$sqlbc.Close()
$conn.Close()
#>
