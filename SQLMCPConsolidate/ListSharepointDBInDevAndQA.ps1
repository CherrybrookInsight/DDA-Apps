<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>


$QueryDEVQAServerList = "SELECT TOP (1000) [SQL Instance Name]
      ,[Environment]
      ,[SQL Version]
      ,[AwO Role]
      ,[WSFC Name]
      ,[AwO Group Name(s)]
      ,[AwO Listener Name(s)]
      ,[AwO Listener IP(s)]
      ,[AwO Listener Port(s)]
      ,[Client Connection String]
  FROM [DDAITADMIN].[dbo].[dbo.MCPSQLList] where [client connection string] like '%t%'"
 
 $QueryListSPDB = "select * from master.databases where name like ''"
 
 $SourceServer = 'PSQLAGA-AL01,1433' 
 $ServerList = Invoke-Sqlcmd -ServerInstance $SourceServer -Query $QueryDEVQAServerList
 
 foreach ($S in $ServerList)
 {
 	$Output = Invoke-Sqlcmd -ServerInstance $S -Query ""
 
 }

$SPDEVQASServers = "AUNDDDVSPDB01", "AUNDDMSSQLQ03"



  