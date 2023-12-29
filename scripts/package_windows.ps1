New-Item -ItemType Directory -Force -Name "dist\tmp"
New-Item -ItemType Directory -Force -Name "out"

# windows setup
Get-ChildItem -Recurse -File -Path "dist" -Filter "*windows-setup.exe" | Copy-Item -Destination "dist\tmp\hiddify-next-setup.exe" -ErrorAction SilentlyContinue
Compress-Archive -Force -Path "dist\tmp\hiddify-next-setup.exe",".github\help\mac-windows\*.url" -DestinationPath "out\hiddify-windows-x64-setup.zip"

# windows portable
xcopy "build\windows\x64\runner\Release" "dist\tmp\hiddify-next" /E/H/C/I/Y
xcopy ".github\help\mac-windows\*.url" "dist\tmp\hiddify-next" /E/H/C/I/Y
Compress-Archive -Force -Path "dist\tmp\hiddify-next" -DestinationPath "out\hiddify-windows-x64-portable.zip" -ErrorAction SilentlyContinue