function Step-ModuleVersion {
    [CmdletBinding(DefaultParameterSetName="Build")]    
    param (
        [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if((Test-Path $_ -PathType Leaf) -and ($_ -notmatch "(\.psd1)")){
                throw "The file specified in the path argument must be a .psd1 Module Manifest"
            }return $true
        })][System.IO.FileInfo]$Path=".\",
        [Parameter(ParameterSetName="Major")][switch]$Major,
        [Parameter(ParameterSetName="Minor")][switch]$Minor,
        [Parameter(ParameterSetName="Build")][switch]$Build
    )

    if (Test-Path $Path -PathType Container) {
        $PathObj = Get-Item $Path
        if (Test-Path "$($PathObj.FullName)\$($PathObj.Name).psd1") {
            Write-Host -ForegroundColor Gray "Using the default manifest file $($PathObj.Name).psd1"
            $Path = "$($PathObj.FullName)\$($PathObj.Name).psd1"
        } else {
            switch ((Get-ChildItem -Path .\ -Filter "*.psd1").Count) {
                0 {throw "No .psd1 manifest found in the specified folder"}
                1 {
                    Write-Host -ForegroundColor Yellow  "The .psd1 manifest file name should generally be same as module and module folder name"
                    $Path = (Get-ChildItem -Path .\ -Filter "*.psd1").FullName
                }
                Default {throw "More than one .psd1 manifest file found, run again specifying the actual file"}
            }
        }
    }

    $CurrentVersion = (Test-ModuleManifest $Path).Version
    switch ($PsCmdlet.ParameterSetName) {
        "Major" {Update-ModuleManifest -Path $Path -ModuleVersion (New-Version ($CurrentVersion.Major + 1) 0)}
        "Minor" {Update-ModuleManifest -Path $Path -ModuleVersion (New-Version $CurrentVersion.Major ($CurrentVersion.Minor + 1))}
        "Build" {Update-ModuleManifest -Path $Path -ModuleVersion (New-Version $CurrentVersion.Major $CurrentVersion.Minor)}
    }
}