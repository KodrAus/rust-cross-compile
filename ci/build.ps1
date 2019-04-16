$ErrorActionPreference = "Stop"

Push-Location "$PSScriptRoot/../"

. "./ci/common.ps1"

Run-Command -Exe cargo -ArgumentList 'build', '--target x86_64-pc-windows-msvc'
Run-Command -Exe cargo -ArgumentList 'build', '--target x86_64-unknown-linux-musl'

Pop-Location