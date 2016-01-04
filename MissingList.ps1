Param([string[]]$InputFile)

$filePhysicalPath1 = "C:\MyScript\"
$filePhysicalPath2 = "C:\MyScript2\"



if (!(Test-Path $InputFile))
{
	Write-Host "File non trovato"
	exit
}

$FoundFiles = 0
$FilesInSecondPath = 0
$MissingFiles = 0
$fileCounter = 0

$Date = Get-Date -UFormat "%Y%m%d%H%M%S"
$Date2 = Get-Date -UFormat "%d%m%Y"

#$Pullfile = "C:\MXF\pull-list.csv"
$Pullfile = $InputFile
$Missingfile = ".\BikeChannel_missing_$Date2.csv"

while (Test-Path $Missingfile)
{
		$fileCounter++
		$Missingfile = ".\BikeChannel_missing_$Date2-$fileCounter.csv"
}


$records = import-csv $Pullfile

$righe = ($records).length

ForEach ($record in $records)
{
	$Clock = $($record."Clock Number")
	$Name = $($record."Product Name")
	$txDate = $($record."Break Date")

	$trafficIDClock = ($Clock)-replace "/","-"
	
	$Videofile = "$filePhysicalPath1$trafficIDClock.*"
	$Videofile2 = "$filePhysicalPath2$trafficIDClock.*"
	#$FileExist = Test-Path $Videofile
	
	if (Test-Path $Videofile)
	{
		Write-Host $trafficIDClock "Found in" $filePhysicalPath1
		$FoundFiles++
	}
	elseif (Test-Path $Videofile2)
	{
		Write-Host $trafficIDClock "Found in" $filePhysicalPath2
		$FoundFiles++
		$FilesInSecondPath++
	}
	else
	{
  	$myTxDate = Get-Date $txDate -Format "dd/MM/yyyy"
  	Write-Host $trafficIDClock","$Name","$myTxDate
		Add-content $Missingfile $Clock","$Name","$myTxDate
		$MissingFiles++
	}
}
Write-Host
Write-Host
Write-Host "-------------------------------------"
Write-Host $righe "Records analyzed"
Write-Host "Found" $FoundFiles "files"
Write-Host $MissingFiles "files are missing!!!"
Write-Host $FilesInSecondPath "are in secondary path only!!!"
Write-Host "Generated missing list file" $Missingfile
Write-Host "-------------------------------------"