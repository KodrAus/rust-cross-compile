$ErrorActionPreference = "Stop"

Push-Location "$PSScriptRoot/../"

Run-Command -Exe cargo -ArgumentList 'build', '--target x86_64-pc-windows-msvc'
Run-Command -Exe cargo -ArgumentList 'build', '--target x86_64-unknown-linux-musl'

Pop-Location