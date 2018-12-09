#Requires -Modules Pester
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$file = Get-ChildItem "$here\$sut"

Describe $file.BaseName -Tags Unit {
    It "is valid PowerShell (Has no script errors)" {
        $contents = Get-Content -Path $file -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.ProcessRunspaceDebugEndEventArgs]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }
    Context "Basic features" {
        . $file
        
        Set-Content TestDrive:\mssql2012.ini 
    }
}