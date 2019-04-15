$ErrorActionPreference = "Stop"

Invoke-WebRequest -OutFile ./rustup-init.exe -Uri https://win.rustup.rs

$ErrorActionPreference = "Continue"

./rustup-init.exe `
  --default-host x86_64-pc-windows-msvc `
  --default-toolchain $env:RUST_TOOLCHAIN `
  -y
if ($LASTEXITCODE) { exit 1 }

$env:Path = "C:\Users\appveyor\.cargo\bin;$env:Path"

rustup target add x86_64-unknown-linux-musl
if ($LASTEXITCODE) { exit 1 }

$ErrorActionPreference = "Stop"