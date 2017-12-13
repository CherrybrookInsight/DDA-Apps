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




function global:Get-WebSites { 
#Requires -Version 2.0 
[CmdletBinding()] 
 Param  
   ([Parameter(Mandatory=$true, 
               Position=0, 
               ValueFromPipeline=$true, 
               ValueFromPipelineByPropertyName=$true)] 
    [String[]]$ComputerName 
   )#End Param 
   Begin 
   { 
   } 
   Process 
   { 
        $ComputerName | ForEach-Object { 
        $Computer = $_; 
        #Get-WmiObject -computer $Computer -authentication 6 -class "IIsWebServerSetting" -namespace "root\microsoftiisv2" | select-object __SERVER, ServerComment, Name; 
		
		$Computer | Write-Host -ForegroundColor green
		Invoke-Command  -ComputerName $Computer { Import-Module WebAdministration; Get-ChildItem -path IIS:\Sites } | ft -AutoSize
		#Out-File -append $WebreportPath
		}
	} 
End 
{ 
} 
} 
Get-WebSites (Get-Content "C:\Users\dzhou\OneDrive - Dimension Data\Documents\GitHubRepo\DDA-Apps\Server-Patching\ServerList.txt") | Export-Csv -Path "C:\Users\dzhou\OneDrive - Dimension Data\Documents\GitHubRepo\DDA-Apps\Server-Patching\WebSites.csv" 
#This runs against a list of servers in a text file and outputs to a CSV 
#to run against a single server and have the output go to the output panel you would run the function like this:   
#Get-WebSites servername