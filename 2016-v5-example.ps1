# Generate Error
function Show-Error {Get-Item C:\doesnotexist.txt}
Show-Error

# Make errors easier to read by changing color
$psISE.Options.ErrorForegroundColor = [System.Windows.Media.Colors]::SkyBlue
Show-Error
$psISE.Options.ErrorForegroundColor = [System.Windows.Media.Colors]::Cyan
Show-Error


# Get errors, use $Error and simplify view
$Error | Group-Object | Sort-Object -Property Count -Descending | Format-Table -Property Count,Name -AutoSize

# Clear all errors in variable
$Error.clear()

