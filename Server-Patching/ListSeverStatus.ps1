cls
$LogFilePath = "C:\Users\dzhou\OneDrive - Dimension Data\Documents\GitHubRepo\DDA-Apps\Server-Patching\ServerCheckLog.txt"
$ServerLit = "AUNDDPDAPT01", "AUNDDPDIIS01", "AUNDDPDIIS02", "AUNDDSSDBP01", "AUNDDSSDBP03", "AUNDDSSDWP01", "AUNDDSSISP01", "AUNDDSSISP02", "AUNDDVSSQL01"
$ServerLit | ft -AutoSize

foreach ($S in $ServerLit)
{	
	$S | Write-Host -ForegroundColor green
	if (gsv "*SQL*" -ComputerName $S)
	{	
	"Connecting to: "+$S | Write-Host -ForegroundColor green 
		$DBList = Invoke-Sqlcmd -serverinstance $S -Query "sp_helpdb"
		$DBList | Out-File $LogFilePath -append -force
		
		$DBList | ft -AutoSize
	}
}

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
