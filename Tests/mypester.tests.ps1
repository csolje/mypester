$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$module = Split-Path -Leaf $here
$Public = @(Get-ChildItem "$here\Public\*.ps1" -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem "$here\Private\*.ps1" -ErrorAction SilentlyContinue)


Describe "Module: $module" -Tags Unit {
    Context "Module Configuration" {
        It "Has a root module file ($module.psm1)" {
            "$here\$module.psm1" | Should -Exist
        }
        It "Is valid PowerShell (Has no syntax errors)" {
            $contents = Get-Content -Path "$here\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
        It "Has a manifest file ($module.psd1)" {
            "$here\$module.psd1" | Should -Exist
        }
        It "Contains a root module path in the manifest (RootModule = '.\$module.psm1')" {
            "$here\$module.psd1" | Should -Exist
            "$here\$module.psd1" | Should -FileContentMatch "$module.psm1"
        }
        It "Has the Public, Private and Required folders" {
            "$here\Public" | Should -Exist
            "$here\Private" | Should -Exist
            "$here\Required" | Should -Exist
        }
        It "Has functions in the folders" {
            "$here\Public\*.ps1" | Should -Exist

        }
        foreach ($CurrentFunction in @($Public + $Private))
        {
            Context "Function: $module::$($CurrentFunction.BaseName)" {
                It "Is valid PowerShell (Has no syntax errors)" {
                    $contents = Get-Content -Path $CurrentFunction -ErrorAction Stop
                    $errors = $null
                    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                    $errors.Count | Should Be 0
                }
                It "Has Pester test" {
                    "$here\Tests\$($CurrentFunction.BaseName).tests.ps1" | Should -Exist
                }
                It "Is not Empty" {
                    $CurrentFunction | Should -Not -BeNullOrEmpty
                }
                It "Has Get-Help comment block" {
                    $CurrentFunction | Should -FileContentMatch "<#"
                    $CurrentFunction | Should -FileContentMatch "#>"
                }
                It "Has Get-Help .SYNOSIS" {
                    $CurrentFunction | Should -FileContentMatch "\.SYNOPSIS"
                }
                It "Has Get-Help .DESCRIPTION" {
                    $CurrentFunction | Should -FileContentMatch "\.DESCRIPTION"
                }
                It "Has Get-Help .PARAMETER" {
                    $CurrentFunction | Should -FileContentMatch "\.PARAMETER"
                }
                It "Has Get-Help .NOTES" {
                    $CurrentFunction | Should -FileContentMatch "\.NOTES"
                }
                It "Has Get-Help .EXAMPLE" {
                    $CurrentFunction | Should -FileContentMatch "\.EXAMPLE"
                }
            }
        }
    }
}