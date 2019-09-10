#Connect to Exchange Online

Set-ExecutionPolicy RemoteSigned

$UserCredential = Get-Credential$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session

#Check if there is a mailbox availible for restore

Get-mailbox -SoftDeletedMailbox

#Get details of the mailbox you want to restore

Get-Mailbox -SoftDeletedMailbox -Identity <NAME OF THE MAILBOX YOU WANT TO RESTORE> | FL Name,ExchangeGuid,PrimarySmtpAddress

#Get details of the mailbox where you want to restore to

Get-Mailbox -Identity <EMAIL ADRES OF THE NEW MAILBOX> | FL Name,ExchangeGuid,PrimarySmtpAddress

#Create Restore with the details found above

New-MailboxRestoreRequest -SourceMailbox e2702dd5-8b61-41dc-a94b-a18f5c4f3f1f -TargetMailbox d0986785-8ebc-4378-9be5-5f9a3f4e3ec9 -AllowLegacyDNMismatch

#Check status of the restore

Get-MailboxRestoreRequest
