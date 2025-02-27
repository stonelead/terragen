Write-Host "Installing required tools via Chocolatey..."
choco install notepadplusplus -y

# Define the URL and local path for the Temurin JRE installer
$TemurinUrl = "https://api.adoptium.net/v3/installer/latest/23/ga/windows/x64/jre/hotspot/normal/eclipse"
$TemurinMsiPath = "$env:TEMP\temurin23.msi"

Write-Host "Downloading and installing Temurin 23 JRE..."

try {
    Invoke-WebRequest -Uri $TemurinUrl -OutFile $TemurinMsiPath
    Write-Host "Download completed successfully."
} catch {
    Write-Error "Failed to download Temurin 23 JRE: $_"
    exit 1
}

try {
    Start-Process msiexec.exe -ArgumentList "/i $TemurinMsiPath /quiet /norestart" -NoNewWindow -Wait
    Write-Host "Temurin 23 JRE installed successfully."
} catch {
    Write-Error "Failed to install Temurin 23 JRE: $_"
    exit 1
}

try {
    Remove-Item $TemurinMsiPath -Force
    Write-Host "Cleaned up installer file."
} catch {
    Write-Warning "Failed to remove installer file: $_"
}
