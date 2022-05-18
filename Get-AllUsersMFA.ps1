# Requirement statement refers to production version of AzureAD, modify the next line to AzureADPreview if you use that
#Requires -Modules MSOnline, AzureAD

# Connect to MSOL and AzureAD
Connect-MsolService
Connect-AzureAD

# Retrieve all users
Write-Progress -id 1 -Activity "Collecting user data" -Status "Retrieving general user information from AzureAD"
$AllUsers = Get-MsolUser -All

#Retrieve all admin roles
Write-Progress -id 1 -Activity "Collecting user data" -Status "Retrieving Admin role assignments"
$admins = Get-AzureADDirectoryRole | Get-AzureADDirectoryRoleMember | Where-Object {$_.ObjectType -eq "User"} | Select-Object -unique

[int]$i = 0; [array]$UsersOut = @(); $StartParse = Get-Date
Write-Progress -id 1 -Activity "Collecting user data" -Status "Parsing user information from AzureAD"
foreach ($User in $AllUsers) {
    $i++; $TimeElapsed = New-TimeSpan -Start $StartParse -End (Get-Date)

    #Parse user info and sign-in logs
    #Note the four trailing lines as these are collecting phone numbers - remove the lines if not needed to respect privacy
    Write-Progress -id 1 -Activity "Collecting user data" -Status "Processing user $i/$($AllUsers.Count): $($User.DisplayName) <$($User.SignInName)>" -CurrentOperation "Parsing user information" `
        -PercentComplete (($i-1)/$AllUsers.Count*100) -SecondsRemaining ($TimeElapsed.TotalSeconds/$i*($AllUsers.Count - $i))
    $UserOut = $User | Select-Object DisplayName, @{l="SignInName";e={$_.UserPrincipalName -replace '^(.*)_(.*)#EXT#@.*','$1@$2'}}, `
        @{l="IsDisabled";e={[int]$_.BlockCredential}}, @{l="IsLicensed";e={[int]$_.IsLicensed}}, @{l="IsSynced";e={[int]([bool]$_.LastDirSyncTime)}}, `
        @{l="IsAdmin";e={[int]($_.ObjectId -in $admins.ObjectId)}}, @{l="IsGuest";e={[int]($_.UserType -eq "Guest")}}, `
        @{l="LegacyMFA";e={switch ($_.StrongAuthenticationRequirements.State) {"Enforced" {2}; "Enabled" {1}; Default {0}}}}, `
        @{l="PhoneAppNotification";e={
            $PAN = switch (($_.StrongAuthenticationMethods.Where({$_.MethodType -eq 'PhoneAppNotification'})).IsDefault) {$true {2}; $false {1}; Default {0}}
            $PAN * [bool]($_.StrongAuthenticationPhoneAppDetails.Count); Remove-Variable PAN
        }}, `
        @{l="PhoneAppOTP";e={
            $PAO = switch (($_.StrongAuthenticationMethods.Where({$_.MethodType -eq 'PhoneAppOTP'})).IsDefault) {$true {2}; $false {1}; Default {0}}
            $PAO * [bool]($_.StrongAuthenticationPhoneAppDetails.Count); Remove-Variable PAO
        }}, `
        @{l="OneWaySMS";e={
            $PMT = switch (($_.StrongAuthenticationMethods.Where({$_.MethodType -eq 'OneWaySMS'})).IsDefault) {$true {2}; $false {1}; Default {0}}
            $PMT * [bool]($_.StrongAuthenticationUserDetails.PhoneNumber); Remove-Variable PMT
        }}, `
        @{l="TwoWayVoiceMobile";e={
            $PMV = switch (($_.StrongAuthenticationMethods.Where({$_.MethodType -eq 'TwoWayVoiceMobile'})).IsDefault) {$true {2}; $false {1}; Default {0}}
            $PMV * [bool]($_.StrongAuthenticationUserDetails.PhoneNumber); Remove-Variable PMV
        }}, `
        @{l="TwoWayVoiceAlternateMobile";e={
            $P2V = switch (($_.StrongAuthenticationMethods.Where({$_.MethodType -eq 'TwoWayVoiceAlternateMobile'})).IsDefault) {$true {2}; $false {1}; Default {0}}
            $P2V * [bool]($_.StrongAuthenticationUserDetails.AlternativePhoneNumber); Remove-Variable P2V
        }}, `
        @{l="TwoWayVoiceOffice";e={
            $POV = switch (($_.StrongAuthenticationMethods.Where({$_.MethodType -eq 'TwoWayVoiceOffice'})).IsDefault) {$true {2}; $false {1}; Default {0}}
            $POV * [bool]($_.PhoneNumber); Remove-Variable POV
        }}, `
        @{l='NumberOfApps';e={$_.StrongAuthenticationPhoneAppDetails.Count}}, `
        @{l="RegisteredPhone";e={($_.StrongAuthenticationUserDetails.PhoneNumber -replace '[ \-\(\)]','')}}, `
        @{l="AlternativePhone";e={$_.StrongAuthenticationUserDetails.AlternativePhoneNumber -replace '[ \-\(\)]',''}}, `
        @{l="MobilePhone";e={$_.MobilePhone -replace '[ \-\(\)]',''}}, `
        @{l="OfficePhone";e={$_.PhoneNumber -replace '[ \-\(\)]',''}}

    $UsersOut += $UserOut
    Remove-Variable UserOut, UserLogs -ErrorAction SilentlyContinue
}
$UsersOut | Sort-Object -Property RolloutGroup,SignInName | Export-Csv -Path "$PSScriptRoot\MFA Report.csv" -NoTypeInformation -Encoding UTF8

Write-Progress -id 1 -Activity "Collected user data" -Complete -Status ("Completed parsing in {0:hh\:mm\:ss}" -f $TimeElapsed)
