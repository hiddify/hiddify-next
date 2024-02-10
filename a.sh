
TARGET_NAME_AppImage="Hiddify-Linux-x64"
TARGET_NAME_deb="Hiddify-Debian-x64"
TARGET_NAME_rpm="Hiddify-rpm-x64"
TARGET_NAME_apk="Hiddify-Android"
TARGET_NAME_aab="Hiddify-Android"
TARGET_NAME_exe="Hiddify-Windows-x64"
TARGET_NAME_dmg="Hiddify-MacOS"
TARGET_NAME_pkg="Hiddify-MacOS-Installer"
TARGET_NAME_ipa="Hiddify-iOS"

ls -R dist/
  mkdir out
  mkdir tmp_out
  
  for EXT in $(echo AppImage,deb,rpm | tr ',' '\n'); do
    KEY=TARGET_NAME_${EXT}
    FILENAME=${!KEY}
    echo mv dist/*/*.$EXT tmp_out/${FILENAME}.$EXT
echo    chmod +x tmp_out/${FILENAME}.$EXT
    if [ "linux" == "linux" ];then
echo      cp ./.github/help/linux/* tmp_out/
    else
echo      cp ./.github/help/mac-windows/* tmp_out/
    fi
    if [[ "linux" == 'ios' ]];then
echo      mv tmp_out/${FILENAME}.$EXT bin/${FILENAME}.$EXT
    else
      cd tmp_out
echo      7z a ${FILENAME}.zip ./
echo      mv *.zip ../out/
      if [[ $EXT == 'AppImage' ]];then
echo        mv ${FILENAME}.$EXT ../out/${FILENAME}.$EXT # added for appimage link
      fi
      cd ..
    fi
  done
