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



# SIG # Begin signature block
# MIIFdgYJKoZIhvcNAQcCoIIFZzCCBWMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaYjWjvRS3nqw7VDEtjxMDZkz
# Js6gggMOMIIDCjCCAfKgAwIBAgIQYWNP3EaehJRF+O2Pb78AoTANBgkqhkiG9w0B
# AQUFADAdMRswGQYDVQQDDBJMb2NhbCBDb2RlIFNpZ25pbmcwHhcNMTgxMjIwMDkw
# MTExWhcNMTkxMjIwMDkyMTExWjAdMRswGQYDVQQDDBJMb2NhbCBDb2RlIFNpZ25p
# bmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD6yo70dTt4/WM6OELW
# HWzP+pDBNxH7wlrtHzKZuozADEM3RfkdTFRWFwQm9kFBP5wpw+zJBE0hV9ORs9jU
# oZwUAmDCKUvBxdu2lV7Uo4dmIabibxn42QbUHbFeWiz+mpehavI+l5b5linIsafn
# JT3ikvhBJU8w6HJVQG0jmGUpuTT9xGwAIr82c1C4tjdl8OMc/gIcDLUVPrp2G8g3
# NtcpIgKrDrnWoxr4aKn99m19jtXggwuUu5eZeMs6uZJhTZWtiEs9ZApkkl1c2elj
# Gzh848RGGlOKwicvMrw3u9sQE89zjwt9G9Cjvq3uTc8qa3RAL0HW1m+BqHs8KYPd
# FuxdAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUFQspejgtFXmDA4hlLTuUik16HgYwDQYJKoZIhvcNAQEFBQAD
# ggEBAB/Wm3D4GI51gz1iU4bR8a2I0lfpvHuD8IrltqkGeqDN7mbrCUfrB/wlmBNb
# L/AtL6K7OMopYpKJ35IexnO/+7R/JHRZKYx44rB3h7bkLKlL0xBk3c2tqghYIXHO
# XbOyDbfCf7QoAzdg8s8nPSLZbx3DUjz9TeY8L1B8WhWwMXrxzDKdiPrbvcbdgBFF
# QYVFhspTfBKMAn5FCL5i5taMN8vR2mKCPTptqyQhNG7vqkVbh9nj4QqLbjGaNUUL
# 4Mmzy47EwO7lD13pErz+mxFVBtau/ry0TUIqgI/9fAw1Bp54rIt0CF+oHTC0Ucxs
# zgTf/QUm64pJgZmwu+uJ3sk+2DIxggHSMIIBzgIBATAxMB0xGzAZBgNVBAMMEkxv
# Y2FsIENvZGUgU2lnbmluZwIQYWNP3EaehJRF+O2Pb78AoTAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUDrLiVvRocnu6SxIVa9bubwefpkowDQYJKoZIhvcNAQEBBQAEggEA5ordEplA
# BgtJ9nj+J6aHPxMuEY4jGhBPfPaVP0OJSawWxJWiYLKAoqtmnLNKkq58VceHpiOk
# 49cmQ4o3HkTk/Wuygwb/ogWu3iOw4/IRio4qOn8IH5TcMcPwjJb1LXehJ5fkfZxG
# B/9jmbiPyyz/DnwvRVWxpMv2JFhcbilqSCNP9Zf49lp3h/cAuxK6OxraFOYxzoj/
# T6gjsRalv+JmYDmpLpReYkrYyty5pimO3wdYxj64HIGDJnOJAyjX7JGXYEx+aCEY
# wD8qkfvt942dpuSa1szXtjGxZwXIVkATjV2Y43tJgkAe9/M0cGtVg+VlbNM4wN73
# HzGQrhghvhcdbg==
# SIG # End signature block
