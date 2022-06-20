


# Need to import the classes/enums in a particular order

$ClassesRoot = "$PSScriptRoot\Classes"
$EnumsRoot  = "$PSScriptRoot\Enums"
$ConcatenatedClassesFile = "$PSScriptRoot\concatenatedClasses.ps1"

# Enums
"" | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8
foreach ($File in (Get-ChildItem -Path $EnumsRoot)) {
    "`r`n#region File $($File.Name)`r`n" | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8 -Append -ErrorAction Stop
    
    Get-Content -Path $File.FullName | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8 -Append -ErrorAction Stop
    
    "`r`n#endregion" | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8 -Append -ErrorAction Stop
}

# Classes
$ClassFiles = @(
    (Get-Item -Path "$ClassesRoot\VivantioQueryItem.Class.ps1"),
    (Get-Item -Path "$ClassesRoot\VivantioQuery.Class.ps1")
)

foreach ($File in $ClassFiles) {
    "`r`n#region File $($File.Name)`r`n" | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8 -Append -ErrorAction Stop
    Get-Content -Path (Join-Path $ClassesRoot 'VivantioQueryItem.ps1') | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8 -Append
    
    "`r`n#region File $($File.Name)`r`n" | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8 -Append -ErrorAction Stop
    Get-Content -Path (Join-Path $ClassesRoot 'VivantioQuery.ps1') | Out-File -FilePath $ConcatenatedClassesFile -Encoding utf8 -Append
}