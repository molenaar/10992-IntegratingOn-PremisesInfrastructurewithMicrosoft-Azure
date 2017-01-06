<#
.SYNOPSIS
    Provides a simple example of a Azure Automation runbook.  

.DESCRIPTION
    This runbook creates an empty file in the root of the local operating system drive and generates a message.
    The runbook takes in an optional string parameter.  If you leave the parameter blank, the default "World" will be used.
    The name of the file and the message consist of the word "Hello " followed by the parameter you provide and the current timestamp
   
.PARAMETER Name
    String value to print as output

.EXAMPLE
    Write-HelloWorld -Name "World"

.NOTES

#>


workflow Write-10992HelloWorld {
    param (
        
        # Optional parameter of type string. 
        # If you do not enter anything, the default value of Name will be World
        [parameter(Mandatory=$false)]
        [String]$Name = "World"
    )

	New-Item -Path "C:\Hello_$Name.txt $(get-date -f yyyy-MM-dd-HH-mm-ss)" -ItemType File -Force
	Write-Output "Hello $Name at $(get-date -f yyyy-MM-dd-HH-mm-ss)"

}