$ErrorActionPreference = "Stop"

Push-Location "$PSScriptRoot/../"

. "./ci/common.ps1"

Invoke-WebRequest -OutFile ./rustup-init.exe -Uri https://win.rustup.rs

Run-Command -Exe ./rustup-init.exe -ArgumentList `
    "--default-host x86_64-pc-windows-msvc", `
    "--default-toolchain $env:RUST_TOOLCHAIN", `
    "-y"

$env:Path = "C:\Users\appveyor\.cargo\bin;$env:Path"

Run-Command -Exe rustup -ArgumentList "target", "add", "x86_64-unknown-linux-musl"

Pop-Location