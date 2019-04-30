$log = "c:\tmp\log.txt"
$url = "https://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-8.0.16.0.msi"
$md5 = "c9cef27aea014ea3aeacabfd7496a092"
$output = "C:\tmp\mysql-installer-community-8.0.16.0.msi"

Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) # VARIABLES #"
Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) log: $($log)"
Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) url $($url)"
Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) md5 $($md5)"

# Download msi file
Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) start download" 
try {
    $status = Invoke-WebRequest -Uri $url -OutFile $output    
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) FailedItem: $($FailedItem) ErrorMessage: $($ErrorMessage)" 
    Break
}

# Check MD5 hashes
Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) Webrequest status: $($status)" 

Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) start download" 

$filemd5 = (Get-FileHash -Path $output -Algorithm MD5).Hash

# Check MD5 hashes
if($md5 -ne $filemd5) {
    Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) MD5 mismatch" 
    break;
}

Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) MD5 is fine" 

# install MySQL Installer Console
try {
    start-process "msiexec" -Verb RunAs -ArgumentList ' /i C:\tmp\mysql-installer-community-8.0.16.0.msi /q /norestart /L*v "C:\tmp\mysql-installer-community-8.0.16.0.log"' -Wait
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) FailedItem: $($FailedItem) ErrorMessage: $($ErrorMessage)" 
    Break
}
# Install MySQL server
try {
    start-process "C:\Program Files (x86)\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe" -Verb RunAs -ArgumentList 'install server;8.0.16;x64 -silent' -Wait
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Out-File -FilePath $log -Append -Encoding ASCII -InputObject "$(get-date) FailedItem: $($FailedItem) ErrorMessage: $($ErrorMessage)" 
    Break
}

# Configure MySQL server ...
