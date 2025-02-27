# Get the latest PaperMC build for the specified release
$PROJECT = "paper"
$MINECRAFT_VERSION = "1.21.1"
$ServerDirectory = "$env:USERPROFILE\Desktop\server"

if (-Not (Test-Path -Path $ServerDirectory)) {
    New-Item -ItemType Directory -Path $ServerDirectory\plugins | Out-Null
    Write-Host "Created server directory at $ServerDirectory"
}

# Fetch the builds JSON using curl
$response = curl -s "https://api.papermc.io/v2/projects/$PROJECT/versions/$MINECRAFT_VERSION/builds"

# Parse JSON using jq to get the latest build with the "default" channel
$LATEST_BUILD = Write-Output $response | jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]'

if ($LATEST_BUILD -ne "null") {
    $JAR_NAME = "${PROJECT}-${MINECRAFT_VERSION}-${LATEST_BUILD}.jar"
    $PAPERMC_URL = "https://api.papermc.io/v2/projects/$PROJECT/versions/$MINECRAFT_VERSION/builds/$LATEST_BUILD/downloads/$JAR_NAME"

    # Download the latest Paper version using curl
    Invoke-WebRequest -Uri $PAPERMC_URL -OutFile "$ServerDirectory\server.jar"
    Write-Host "Download completed"
} else {
    Write-Host "No stable build for version $MINECRAFT_VERSION found :("
}

# Create start.bat
Write-Host "Creating start.bat file..."
$StartBatContent = "@echo off

java -Xms9216M -Xmx9216M -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dcom.mojang.eula.agree=true -jar --add-exports=java.desktop/sun.awt.image=ALL-UNNAMED server.jar -o false nogui

pause"
Set-Content -Path "$ServerDirectory\start.bat" -Value $StartBatContent -Force
Write-Host "start.bat created successfully."