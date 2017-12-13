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

		Invoke-Command  -ComputerName AUNDDPDIIS02 { Import-Module WebAdministration; Get-ChildItem -path IIS:\Sites | ft -AutoSize } 
		Invoke-Command  -ComputerName AUNDDPDIIS01 { Import-Module WebAdministration; Get-ChildItem -path IIS:\Sites  | ft -AutoSize } 