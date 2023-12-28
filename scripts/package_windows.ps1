New-Item -ItemType Directory -Force -Name "out"

# windows setup
Get-ChildItem -Recurse -File -Path "dist" -Filter "*windows-setup.exe" | Copy-Item -Destination "out/hiddify-next-setup.exe" -ErrorAction SilentlyContinue
Compress-Archive -Force -Path "out/hiddify-next-setup.exe",".github/help/mac-windows/*.url" -DestinationPath "out/hiddify-windows-x64-setup.zip"

# windows portable
Copy-Item -Force -Path "build/windows/x64/runner/Release/*" -Destination "out/hiddify-next"
Compress-Archive -Force -Path "out/hiddify-next" -DestinationPath "out/hiddify-windows-x64-portable.zip"