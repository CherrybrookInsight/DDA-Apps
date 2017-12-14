<#
.SYNOPSIS
   List SAP SQL DB and current version
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>


$SQLSAPPRD = 'AUSAPDB1'
$QueryToRun = 'select @@servername [server_name], @@version [os/sql version]'
Get-Date -Format f;
$Output = Invoke-Sqlcmd -ServerInstance $SQLSAPPRD -Query $QueryToRun
$Output | ft -AutoSize

$Output | fl *
