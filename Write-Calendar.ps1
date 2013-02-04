param
(
    [int] $month,
    [int] $year
)

Set-Variable -name daysLine -option Constant -value "Su Mo Tu We Th Fr Sa "

if ($year -lt 0)
{
    Write-Host "Year parameter must be greater than 0" -ForegroundColor "red"
    exit 1
}
if ($month -lt 0)
{
    Write-Host "Month parameter must be between 1 and 12" -ForegroundColor "red"
    exit 1
}
if (($month -gt 12) -and ($year -eq 0))
{
    $year = $month
    $month = 0
}
elseif (($month -gt 12) -and ($year -ne 0))
{
    Write-Host "Month parameter must be between 1 and 12" -ForegroundColor "red"
    exit 1
}

function Print-Month ($month, $year)
{
    $firstDayOfMonth = Get-Date -month $month -day 1 -year $year
    $lastDayOfMonth = (Get-Date -month $firstDayOfMonth.AddMonths(1).Month -day 1 -year $firstDayOfMonth.AddMonths(1).Year).AddDays(-1)
    
    $header = (Get-Date $firstDayOfMonth -Format MMMM) + " " + $firstDayOfMonth.Year
    Write-Host ""
    Write-Host ((" " * (($daysLine.Length - $header.Length) / 2)) + $header)
    Write-Host $daysLine
    
    for ($day = $firstDayOfMonth; $day -le $lastDayOfMonth; $day = $day.AddDays(1))
    {
        $color = "white"
        
        if($day.date -eq (get-date).date)
        {
            $color = "red"
        }
        
        if ($day.day -eq 1)
        {
            Write-Host (" " * 3 * [int](Get-Date $day -uformat %u)) -noNewLine
        }
        
        Write-Host ((Get-Date $day -Format dd).ToString() + " ") -noNewLine -ForegroundColor $color
        
        if ($day.DayOfWeek -eq "Saturday")
        {
            Write-Host ""
        }
    }
    
    if ($lastDayOfMonth.DayOfWeek -ne "Saturday")
    {
        Write-Host ""
    }
    Write-Host ""
}

function Print-Year ($year)
{
    Write-Host ""
    
    for($month = 1; $month -le 12; $month += 3)
    {
        $header = ""
        
        for ($i = $month; $i -lt $month + 3; $i++)
        {
            $tempHeader = (Get-Date -month $i -Format MMMM) + " " + $year.ToString()
            $header += ((" " * (($daysLine.Length - $tempHeader.Length) / 2)) + $tempHeader + (" " * (($daysLine.Length - $tempHeader.Length) / 2)))
            $header += "  "
        }
        
        Write-Host $header
        Write-Host (($daysLine + "  ") * 3)
        
        $dayCounts = (1, 1, 1)

        $i = 0
        while ($dayCounts[0] -le (Get-Date -day 1 -month ($month + 1) -year $year).AddDays(-1).day -or `
               $dayCounts[1] -le (Get-Date -day 1 -month ($month + 2) -year $year).AddDays(-1).day -or `
               $dayCounts[2] -le (Get-Date -day 1 -month (($month + 3) % 12) -year $year).AddDays(-1).day)
#        for ($i = 0; $i -lt 3;)
        {
            $dayOfMonth = $dayCounts[$i]
            $dayCounts[$i]++
            $dayOffset = [int](Get-Date -day 1 -month ($month + $i) -year $year -uformat %u)
            $color = "white"
            
            if ($dayOfMonth -eq 1)
            {
                Write-Host (" " * 3 * $dayOffSet) -noNewLine
            }
                
            if ($dayOfMonth -le (Get-Date -day 1 -month ((($i + $month) % 12) + 1) -year $year).AddDays(-1).day)
            {
                if ((Get-Date -day $dayOfMonth -month ((($i + $month - 1) % 12) + 1) -year $year).date -eq (Get-Date).date)
                {
                    $color = "red"
                }
                
                Write-Host ((Get-Date -month ($i + $month) -day $dayOfMonth -year $year -Format dd).ToString() + " ") -noNewLine -ForeGroundcolor $color
            }
            else
            {
                Write-Host "   " -noNewLine
            }
            
            if ((($dayOfMonth + $dayOffset) % 7) -eq 0)
            {
                $i = ($i + 1) % 3
                Write-Host "  "-noNewLine
                
                if ($i -eq 0)
                {
                    Write-Host ""
                }
            }
        }
        
        Write-Host ""
        
        $dayCounts = (1, 1, 1)
    }
}

if (($month -eq 0) -and ($year -eq 0))
{
    Print-Month (Get-Date).Month (Get-Date).Year
}
elseif (($month -ne 0) -and ($year -eq 0))
{
    Print-Month $month (Get-Date).Year
}
elseif (($month -ne 0) -and ($year -ne 0))
{
    Print-Month $month $year
}
else
{
    Print-Year($year)
}
