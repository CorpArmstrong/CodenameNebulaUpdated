# ---------------------------------------------------------------------------
# ucc_safeheap.ps1 - Run ucc.exe with the Windows debug heap.
#
# Why this exists: the stock ConSys.dll writes past the end of every
# ConEventAnimation it imports. Its C++ class is 0x60 bytes, but the object
# is allocated at the size of the ConSys.u script class, 0x58, and
# DConEventAnimation::ImportFile stores the bFinishAnim/bLoopAnim bits at
# 0x5C. Whether those bytes land on a live neighbour depends on the randomized
# low-fragmentation heap, so OpheliaDocksAndL1.con (10 animation events)
# crashed about one compile in four ("General protection fault",
# FArray::Realloc in CONVERSATION IMPORT). Found 2026-10-09 by running ucc
# under the debug heap, which reports "Heap block ... modified past requested
# size of 58" for each one.
#
# The debug heap -- what Windows gives a process started under a debugger --
# pads every block, so the stray bytes land in the padding. It is switched on
# through this one process's NtGlobalFlag (SafeHeapRun.cs); nothing in the
# system or in the game's files changes. Measured: 0 crashes in 60 isolated
# imports of OpheliaDocksAndL1.con, against ~25% without it.
#
# Usage: ucc_safeheap.ps1 -SystemDir <Deus Ex\System> [ucc arguments...]
# The exit code is ucc's; ucc's output goes to this script's output.
# ---------------------------------------------------------------------------
param(
    [Parameter(Mandatory = $true)][string]$SystemDir,
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$UccArgs
)

Add-Type -Path (Join-Path $PSScriptRoot 'SafeHeapRun.cs')

$ucc = Join-Path $SystemDir 'ucc.exe'
$commandLine = '"' + $ucc + '"'
foreach ($a in $UccArgs) { $commandLine += ' ' + $a }

exit [SafeHeapRun]::Run($commandLine, $SystemDir)
