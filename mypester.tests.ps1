$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$module = Split-Path -Leaf $here

Describe "Module: $module" -Tags Unit {
    Context "Module Configuration" {
        It "Has a root module file ($module.psm1)" {
            "$here\$module.psm1" | Should Exist
        }
        It "Is valid PowerShell (Has no errors)" {
            $contents = Get-Content -Path "$here\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
        It "Has a manifest file ($module.psd1)" {
            "$here\module.psd1" | Should Exist
        }
        It "Contains a root module path in the manifest (RootModule = '.\$module.psm1')" {
            "$here\$module.psd1" | Should Exist
            "$here\$module.psd1" | Should Contain "\.\\$module.psm1"
        }
        It "Has the Public, Private and Required folders" {
            "$here\Public" | Should Exist
            "$here\Private" | Should Exist
            "$here\Required" | Should Exist
        }
        It "Has functions in the folders" {
            "$here\Public\*.ps1" | Should Exist
            "$here\Private\*.ps1" | Should Exist
            "$here\Required\*.ps1" | Should Exist
        }
        $Functions = Get-ChildItem "$here\Public\*.ps1" -ErrorAction SilentlyContinue
        $Functions += Get-ChildItem "$here\Private\*.ps1" -ErrorAction SilentlyContinue
        $Functions += Get-ChildItem "$here\Required\*.ps1" -ErrorAction SilentlyContinue

        foreach ($CurrentFunction in $Functions) {
            Context "Function: $module::$(CurrentFunction.BaseName)" {
                It "Has Pester test" {
                    "$here\Tests\$CurrentFunction"
                }
            }
        }
    }
}