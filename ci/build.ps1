$ErrorActionPreference = "Stop"

Push-Location "$PSScriptRoot/../"

cargo build --target x86_64-pc-windows-msvc
cargo build --target x86_64-unknown-linux-musl

Pop-Location