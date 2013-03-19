<#
.SYNOPSIS
Writes out calendar elements, either a single month or an entire year depending on the inputs.

.PARAMETER Month
If specified, will limit output to a single month with this numeral value.

.PARAMETER Year
If specified, will output an entire year.

.NOTES
This script has some functionality which many would consider weird or inconsistent. Specifically, if a month is specifed and a year is not, then the output is typically the calendar for the input month and the current year. However, if the specified month is greater than 12, then it's treated as a year and the whole year is outputted.

The reason for this is to emulate the *NIX cal function, which behaves similarly. That is, cal outputs the current month, cal 2012 outpus the calendar for 2012 and cal 05 2012 outputs the calendar for May 2012.

That is pretty much how Write-Calendar works with the exception that Write-Calendar 05 will write out the calendar for May of the current year whereas cal will output the calendar for the year 5.

Since the point of this script is to emulate cal's functionality I will probably not change it to make it more consistent.

.EXAMPLE
Write-Calendar
Outputs the current month.

.EXAMPLE
Write-Calendar 2013
Outputs the calendar for 2013.

.EXAMPLE
Write-Calendar 04 2011
Outputs the calendar for April, 2011.

.EXAMPLE
Write-Calendar 7
Outputs the calendar for September of this year.
#>
param (
    [int] $Month = (Get-Date).Month,
    [int] $Year = (Get-Date).Year
)

Set-Variable -name daysLine -option Constant -value "Su Mo Tu We Th Fr Sa "

if ($year -lt 0) {
    throw "Year parameter must be greater than 0"
}

if ($month -lt 0) {
    throw "Month parameter must be between 1 and 12"
}

if (($month -gt 12) -and ($year -eq (Get-Date).Year)) {
    $year = $month
    $month = 0
}
elseif (($month -gt 12) -and ($year -ne (Get-Date).Year)) {
    throw "Month parameter must be between 1 and 12"
}

function Print-Month ($month, $year) {
    $firstDayOfMonth = Get-Date -month $month -day 1 -year $year
    $lastDayOfMonth = (Get-Date -month $firstDayOfMonth.AddMonths(1).Month -day 1 -year $firstDayOfMonth.AddMonths(1).Year).AddDays(-1)
    
    $header = (Get-Date $firstDayOfMonth -Format MMMM) + " " + $firstDayOfMonth.Year
    Write-Host
    Write-Host ((" " * (($daysLine.Length - $header.Length) / 2)) + $header)
    Write-Host $daysLine
    
    for ($day = $firstDayOfMonth; $day -le $lastDayOfMonth; $day = $day.AddDays(1)) {
        $color = "white"
        
        if ($day.date -eq (get-date).date) {
            $color = "red"
        }
        
        if ($day.day -eq 1) {
            Write-Host (" " * 3 * [int](Get-Date $day -uformat %u)) -NoNewLine
        }
        
        Write-Host ((Get-Date $day -Format dd).ToString() + " ") -NoNewLine -ForegroundColor $color
        
        if ($day.DayOfWeek -eq "Saturday") {
            Write-Host
        }
    }
    
    if ($lastDayOfMonth.DayOfWeek -ne "Saturday") {
        Write-Host
    }

    Write-Host
}

function Print-Year ($year) {
    Write-Host
    
    for($month = 1; $month -le 12; $month += 3) {
        $header = ""
        
        for ($i = $month; $i -lt $month + 3; $i++) {
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
               $dayCounts[2] -le (Get-Date -day 1 -month (($month + 3) % 12) -year $year).AddDays(-1).day) {

            $dayOfMonth = $dayCounts[$i]
            $dayCounts[$i]++
            $dayOffset = [int](Get-Date -day 1 -month ($month + $i) -year $year -uformat %u)
            $color = "white"
            
            if ($dayOfMonth -eq 1) {
                Write-Host (" " * 3 * $dayOffSet) -NoNewLine
            }
                
            if ($dayOfMonth -le (Get-Date -day 1 -month ((($i + $month) % 12) + 1) -year $year).AddDays(-1).day) {
                if ((Get-Date -day $dayOfMonth -month ((($i + $month - 1) % 12) + 1) -year $year).date -eq (Get-Date).date) {
                    $color = "red"
                }
                
                Write-Host ((Get-Date -month ($i + $month) -day $dayOfMonth -year $year -Format dd).ToString() + " ") -NoNewLine -ForeGroundcolor $color
            }
            else {
                Write-Host "   " -NoNewLine
            }
            
            if ((($dayOfMonth + $dayOffset) % 7) -eq 0) {
                $i = ($i + 1) % 3
                Write-Host "  " -NoNewLine
                
                if ($i -eq 0) {
                    Write-Host
                }
            }
        }
        
        Write-Host
        $dayCounts = (1, 1, 1)
    }
}

if ($month -ne 0) {
    Print-Month $month $year
}
else {
    Print-Year $year
}
