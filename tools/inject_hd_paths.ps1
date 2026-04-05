param(
    [string]$ArgsFile
)

$args_lines = Get-Content $ArgsFile
$IniFile = ($args_lines[0]).ToString().Trim()
$NvPath = ($args_lines[1]).ToString().Trim()
$HdtpTexPath = ($args_lines[2]).ToString().Trim()
$HdtpSysPath = ($args_lines[3]).ToString().Trim()

if ($NvPath -eq '.') { $NvPath = '' }
if ($HdtpTexPath -eq '.') { $HdtpTexPath = '' }
if ($HdtpSysPath -eq '.') { $HdtpSysPath = '' }

$ini = [System.IO.File]::ReadAllLines($IniFile)

# Remove any existing HD lines and stale NV/HDTP paths
$ini = $ini | Where-Object {
    $_ -notmatch '; HD Textures' -and
    $_ -notmatch 'NewVision' -and
    $_ -notmatch 'HDTP' -and
    $_ -notmatch 'New Vision'
}

# Build HD lines
$hdLines = @('; HD Textures (auto-detected by cnn hd)')
if ($NvPath) { $hdLines += "Paths=$NvPath\*.utx" }
if ($HdtpTexPath) { $hdLines += "Paths=$HdtpTexPath\*.utx" }
if ($HdtpSysPath) { $hdLines += "Paths=$HdtpSysPath\*.u" }

# Find the FIRST base game Paths= line (ones starting with ..\Textures, ..\System, ..\Maps, ..\Sounds, ..\Music)
# Insert HD paths BEFORE it so they take priority
$firstBaseIdx = -1
for ($i = 0; $i -lt $ini.Length; $i++) {
    if ($ini[$i] -match '^Paths=\.\.\\(Textures|System|Maps|Sounds|Music)\\') {
        $firstBaseIdx = $i
        break
    }
}

if ($firstBaseIdx -ge 0) {
    $result = $ini[0..($firstBaseIdx-1)] + $hdLines + $ini[$firstBaseIdx..($ini.Length-1)]
    [System.IO.File]::WriteAllLines($IniFile, $result)
    Write-Host "  Injected $($hdLines.Length - 1) HD path(s) before base game paths (line $($firstBaseIdx + 1))"
} else {
    # Fallback: insert after the last Paths= line
    $lastPathIdx = -1
    for ($i = 0; $i -lt $ini.Length; $i++) {
        if ($ini[$i] -match '^Paths=') { $lastPathIdx = $i }
    }
    if ($lastPathIdx -ge 0) {
        $result = $ini[0..$lastPathIdx] + $hdLines + $ini[($lastPathIdx+1)..($ini.Length-1)]
        [System.IO.File]::WriteAllLines($IniFile, $result)
        Write-Host "  Injected $($hdLines.Length - 1) HD path(s) after line $($lastPathIdx + 1)"
    } else {
        Write-Host "  ERROR: No Paths= lines found in $IniFile"
    }
}
