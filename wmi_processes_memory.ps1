# Usage: 	.\wmi_processes_memory.ps1 
#			.\wmi_processes_memory.ps1 <machineName>

# Parameters:
#			<machineName>: The name of the machine from which to gather the information.  If not specified, information is gathered from the local machine

# Pre-requisites
# 1.	The PowerShell execution policy must be set to allow the execution of an unsigned script or you must sign the script such that it can be trusted
#		See: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1
# 2.	The executing account must be an administrator on the target machine

# Questions/Comments
# dkrouk@esri.com


param	(
		[Parameter(Mandatory=$false)][string]$machine='.'
		)

# establish the output filename
$ext = '.csv'
if (!$machine)
{
	$machine = (Get-Content env:computername)
	#$outFileName = (Get-Content env:computername) + "_processes_memory_$(Get-Date -f yyyy-MM-dd-HHmmss)$ext"
}
elseif ($machine -eq '.')
{
	$machine = (Get-Content env:computername)
	#$outFileName = (Get-Content env:computername) + "_processes_memory_$(Get-Date -f yyyy-MM-dd-HHmmss)$ext"
}
#else
#{
#	$outFileName = $machine + "_processes_memory_$(Get-Date -f yyyy-MM-dd-HHmmss)$ext"
#}

$outFileName = $machine + "_processes_memory_$(Get-Date -f yyyy-MM-dd-HHmmss)$ext"

Write-Host "Attempting to acquire process information from $machine ..."

# Get process information
$processes = Get-CimInstance Win32_Process -ComputerName $machine | select ProcessId, Name, WorkingSetSize, PeakWorkingSetSize, VirtualSize, PeakVirtualSize, CommandLine, PSComputerName

Write-Host "Writing file header ..."
Add-Content -Path $outFileName -Value "ComputerName, ProcessId, ProcessName, WorkingSetSizeB, PeakWorkingSetSizeKB, VirtualSizeB, PeakVirtualSize, CommandLine, ServiceName"

Write-Host "Parsing process information from $machine ..."

# Create a csv line for each process 
foreach ($process in $processes)
{
	#replace commas in command line with spaces (for csv output)
	$commandLine = $process.CommandLine 
	$commandLine = $commandLine -replace ',',' ' 
	
	# create an output line stub
	$resultLine = $process.PSComputerName + ', ' +  $process.ProcessId.ToString() + ', ' + $process.Name + ', ' + $process.WorkingSetSize.ToString() + ', ' + $process.PeakWorkingSetSize.ToString() + ', ' + $process.VirtualSize.ToString() + ', ' + $process.PeakVirtualSize.ToString() + ', ' + $commandLine 
	if ($commandLine)
	{
		$marker = '-Dservice='
		if ($commandLine.Contains($marker))
		{
			# Extract the service name from the command line 
			# There is a command line with our marker, extract the service name
			$start = $commandLine.IndexOf($marker)
			$start = $start + $marker.Length # the end of the marker
			$stop = $commandLine.IndexOf(' ',$start) # the next space
			$serviceName = $commandLine.Substring($start, ($stop - $start))
			$resultLine = $resultLine + ', ' + $serviceName
		}
		else
		{
			# There is a command line, but it does not contain our marker, report other attributes only 
			$resultLine = $resultLine + ', N/A '
		}
	}
	else
	{
		# No command line, report other attributes only
		$resultLine = $resultLine + ', N/A '
	}
	
	Add-Content -Path $outFileName -Value $resultLine
	#Write-Host $resultLine
}

Write-Host "Processing complete.  Output file: $outFileName"



