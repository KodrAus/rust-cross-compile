function Run-Command
{
    Param ($Exe, $ArgumentList)

    # For commands that treat stderr like stdetc
    $out = New-TemporaryFile
    $err = New-TemporaryFile
    $r = Start-Process $Exe -ArgumentList $ArgumentList -Wait -PassThru -RedirectStandardOut $out.FullName -RedirectStandardError $err.FullName

    Write-Output "STDOUT"
    Get-Content -Path $out.FullName
    Write-Output ""

    Write-Output "STDERR"
    Get-Content -Path $err.FullName
    Write-Output ""
    
    Remove-Item $out.FullName
    Remove-Item $err.FullName

    if ($r.ExitCode -ne 0) {
        exit $r.ExitCode
    }
}
