# Get public, private and required function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Required = @( Get-Item -Path $PSScriptRoot\Required\Required.ps1 )

# Dot source the files
Foreach ($import in @($Public + $Private + $Required)) {
    Try {
        . $import.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.BaseName