New-Item -ItemType Directory -Force -Name "dist/tmp"
New-Item -ItemType Directory -Force -Name "out"

# windows setup
Get-ChildItem -Recurse -File -Path "dist" -Filter "*windows-setup.exe" | Copy-Item -Destination "dist/tmp/hiddify-next-setup.exe" -ErrorAction SilentlyContinue
Compress-Archive -Force -Path "dist/tmp/hiddify-next-setup.exe",".github/help/mac-windows/*.url" -DestinationPath "out/hiddify-windows-x64-setup.zip"

# windows portable
Copy-Item -Force -Path "build/windows/x64/runner/Release/*",".github/help/mac-windows/*.url" -Destination "dist/tmp/hiddify-next"
Compress-Archive -Force -Path "dist/tmp/hiddify-next" -DestinationPath "out/hiddify-windows-x64-portable.zip"