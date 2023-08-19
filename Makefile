BINDIR=./libcore/bin
ANDROID_OUT=./android/app/libs
DESKTOP_OUT=./libcore/bin
GEO_ASSETS_DIR=./assets/core
LIBS_DOWNLOAD_URL=https://github.com/hiddify/hiddify-next-core/releases/download/draft

get:
	flutter pub get

gen:
	dart run build_runner build --delete-conflicting-outputs

translate:
	dart run slang

android-release:
	flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi

windows-release:
	flutter_distributor package --platform windows --targets exe

linux-release:
	flutter_distributor package --platform linux --targets appimage

macos-realase:
	flutter build macos --release &&\
	tree ./build/macos/Build &&\
    create-dmg  --app-drop-link 600 185 "hiddify-amd64.dmg" ./build/macos/Build/Products/Release/hiddify-clash.app

android-libs: 
	mkdir -p $(ANDROID_OUT)
	curl -L $(LIBS_DOWNLOAD_URL)/hiddify-libcore-android.aar.gz | gunzip > $(ANDROID_OUT)/libcore.aar

windows-libs:
	mkdir -p $(DESKTOP_OUT)
	curl -L $(LIBS_DOWNLOAD_URL)/hiddify-libcore-windows-amd64.dll.gz | gunzip > $(DESKTOP_OUT)/libcore.dll

linux-libs:
	mkdir -p $(DESKTOP_OUT)
	curl -L $(LIBS_DOWNLOAD_URL)/hiddify-libcore-linux-amd64.so.gz | gunzip > $(DESKTOP_OUT)/libcore.so

macos-libs:
	mkdir -p $(DESKTOP_OUT)/ &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify-clashlib-macos-amd64.so.gz | gunzip > $(DESKTOP_OUT)/libclash.dylib

get-geo-assets:
	curl -L https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db -o $(GEO_ASSETS_DIR)/geoip.db
	curl -L https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db -o $(GEO_ASSETS_DIR)/geosite.db

build-headers:
	make -C libcore -f Makefile headers && mv $(BINDIR)/hiddify-libcore-headers.h $(BINDIR)/libcore.h

build-android-libs:
	make -C libcore -f Makefile android && mv $(BINDIR)/hiddify-libcore-android.aar $(ANDROID_OUT)/libcore.aar

build-windows-libs:
	make -C libcore -f Makefile windows-amd64 && mv $(BINDIR)/hiddify-libcore-windows-amd64.dll $(DESKTOP_OUT)/libcore.dll

build-linux-libs:
	make -C libcore -f Makefile linux-amd64 && mv $(BINDIR)/hiddify-libcore-linux-amd64.dll $(DESKTOP_OUT)/libcore.so