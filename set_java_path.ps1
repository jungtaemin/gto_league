$p = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($p -notlike '*Eclipse Adoptium*') {
    [Environment]::SetEnvironmentVariable('Path', "$p;C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin", 'User')
    Write-Output 'Added JDK to PATH'
} else {
    Write-Output 'JDK already in PATH'
}
