# ---------------------------------------------------------------------------
# cnn_snapdiff.ps1 - Compare two SNAP dumps saved by cnn_bridge.ps1.
#
# Prints only the keys whose values differ. Level package prefixes
# ("Package3.", "06_OpheliaL2.") are dropped first: every load renames the
# level package, which is not a real difference.
#
# Usage: cnn_snapdiff.ps1 before after [-SnapDir <dir>]
# ---------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$A,
    [Parameter(Mandatory=$true)][string]$B,
    [string]$SnapDir = (Join-Path $env:TEMP 'cnn_snaps')
)

function Load($n) {
    $h = [ordered]@{}
    foreach ($l in Get-Content (Join-Path $SnapDir "$n.txt")) {
        $l = $l -replace '(Package[0-9]+|0[0-9]_[A-Za-z0-9]+)[.]', ''
        $k = ($l -split '=', 2)[0]
        $v = if ($l.Contains('=')) { ($l -split '=', 2)[1] } else { '' }
        $h[$k] = $v
    }
    $h
}

$x = Load $A
$y = Load $B
$keys = @($x.Keys) + @($y.Keys | Where-Object { -not $x.Contains($_) })
$same = 0
foreach ($k in $keys) {
    if ($k -eq 'snap') { continue }
    if ($x[$k] -ne $y[$k]) { "~ $k"; "    $A : $($x[$k])"; "    $B : $($y[$k])" } else { $same++ }
}
"($same keys identical)"
