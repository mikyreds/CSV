Param([string[]]$InputFile)


[bool]$oldLogs = $true

if (!(Test-Path $InputFile))
{
Write-Host "File non trovato"
exit
}

$FoundRecords = 0

$AsRunFile = $InputFile

$Date = Get-Date -UFormat "%Y%m%d%H%M%S"
$Date2 = Get-Date -UFormat "%H%M%S"

$Asfile = "C:\MXF\AS_Run_$Date"

if($oldLogs)
{
	$header = "Time","Date","XXX","Title","ClockID","Duration"
	$records = import-csv -Delimiter "`t" -Header $header $AsRunFile
}
else
{
		$header = "Date","Time","Type","START","GUID","Title","XXX","ClockID","YYY","Duration","DurationSeconds","ZZZ"
		$records = import-csv -Header $header $AsRunFile
}

$righe = ($records).length

#WriteHeader
$myDate = $records[0].Date
$myNewDate = ($myDate)-replace "/",""
#$myNewDatdTrimmed = $myNewDate.remove(4,2)
$myNewDateDD = $myNewDate.substring(0,4)
$myNewDateYY = $myNewDate.substring(6,2)	
	
Add-Content $Asfile $Date2'00SMSPOSTED 001 '
#Add-Content $Asfile $Date2'01BIKE'$myNewDatdTrimmed
Add-Content $Asfile $Date2'01BIKE'$myNewDateDD$myNewDateYY

ForEach ($record in $records)
{
	if ($oldLogs -or ($record.START -eq "START"))
	{
		$FoundRecords++
		$clock = $record.ClockID
		$myTitle = $record.Title

		$myTime = $record.Time
	
		$myTime = $myTime -replace "00:","24:"
		$myTime = $myTime -replace "01:","25:"
		$myTime = $myTime -replace "02:","26:"
		$myTime = $myTime -replace "03:","27:"
		$myTime = $myTime -replace "04:","28:"
		$myTime = $myTime -replace "05:","29:"
	
	
		if($oldLogs)
		{
			$myDuration = $record.Duration
			$myMinutes = $myDuration.substring(3,2)
			$mySeconds = $myDuration.substring(6,2)
			
			#$myNewTS = [timespan]::Parse($myDuration)
			#$myDuration = $myNewTS.TotalSeconds
			
			$myDuration = ($mySeconds -as[int]) + (($myMinutes -as[int])*60)
			if($myDuration -ge 999) {$myDuration = 999}
			
			$myStringDuration = $myDuration -as[string]
			$myStringDuration = $myStringDuration.PadLeft(3,'0')
		}
		else
		{
				$myDuration = $record.DurationSeconds
		}

		$myTime = $myTime -replace ':',''
		$myTime = $myTime.Substring(0,6)
	
		$clock = 'SSC-KFDG006-03'
		$myClock = $clock -replace '-','/'
	
		#Write-Host $myTime'03    0000000000000'$myStringDuration$myClock
		Add-Content $Asfile $myTime'03    0000000000000'$myStringDuration$myClock
	}
}


#Write footer
$StringFoundRecords = $FoundRecords.ToString("000000")
$myTempString = '99999998'
Add-Content $Asfile $myTempString$StringFoundRecords

$FoundRecords = ($FoundRecords + 2)
$myTempString = '99999999'
$StringFoundRecords = $FoundRecords.ToString("000000")
Add-Content $Asfile $myTempString$StringFoundRecords


#------------- Report -------------#
Write-Host 'AsRun file contains:' $righe 'rows'
Write-Host $FoundRecords 'usefull record found'
