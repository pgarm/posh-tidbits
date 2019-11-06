function Set-CustomTemplates {
    param (
        [ValidateScript({
            if(-Not ($_ | Test-Path)){
                throw "File $_ does not exist"
            } elseif (-Not ($_ | Test-Path -PathType Leaf)) {
                throw "The Template argument must be a file"
            } elseif ($_ -notmatch '(\.potx|\.pptx)$') {
                throw "The Template argument must point to a .potx or .pptx file"
            }
            return $true
        })][System.IO.FileInfo]$TemplateFile = "$PSScriptRoot\blank.potx",
        [System.IO.FileInfo]$Path = "$env:OneDrive\Templates"
    )
    
    if (-not ($Path | Test-Path)) {
        New-Item -Path $Path -ItemType Directory
    } elseif ($Path | Test-Path -PathType Leaf) {
        throw "There's a file with the same name as the folder specified for Path - please remove or rename it"
    } else {
        Write-Verbose "The path requested already exists - no need to create it"
    }

    if(-Not ($TemplateFile | Test-Path)){
        throw "File $_ does not exist"
    } else {
        Copy-Item -Path $TemplateFile -Destination "$Path\blank.potx"
    }

    $RegKeyGeneral = [PSCustomObject]@{
        Key = 'HKCU:\Software\Microsoft\Office\16.0\Common\General'
        Value = 'UserTemplates'
    }
    $RegKeysPersonal = @(
        [PSCustomObject]@{
            Key = 'HKCU:\Software\Microsoft\Office\16.0\PowerPoint\Options'
            Value = 'PersonalTemplates'
        },
        [PSCustomObject]@{
            Key = 'HKCU:\Software\Microsoft\Office\16.0\Word\Options'
            Value = 'PersonalTemplates'
        },
        [PSCustomObject]@{
            Key = 'HKCU:\Software\Microsoft\Office\16.0\Excel\Options'
            Value = 'PersonalTemplates'
        },
        [PSCustomObject]@{
            Key = 'HKCU:\Software\Microsoft\Office\16.0\Publisher\Preferences'
            Value = 'PersonalTemplates'
        }
    )
    
    New-ItemProperty -Path $RegKeyGeneral.Key -Name $RegKeyGeneral.Value -PropertyType String -Value $Path
    foreach ($RegKeyPersonal in $RegKeysPersonal) {
        New-ItemProperty -Path $RegKeyPersonal.Key -Name $RegKeyPersonal.Value -PropertyType String -Value $Path
    }

}