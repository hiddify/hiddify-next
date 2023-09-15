include dependencies.properties

BINDIR=./libcore/bin
ANDROID_OUT=./android/app/libs
DESKTOP_OUT=./libcore/bin
GEO_ASSETS_DIR=./assets/core

BRANCH=$(shell git branch --show-current)
VERSION=$(shell git describe --tags --abbrev=0 || echo "unknown version")

CORE_NAME=hiddify-libcore
ifeq ($(BRANCH),RELEASE)
CORE_URL=https://github.com/hiddify/hiddify-next-core/releases/download/v$(core.version)
else
CORE_URL=https://github.com/hiddify/hiddify-next-core/releases/download/draft
endif

ifeq ($(BRANCH),RELEASE)
FLAVOR=prod
else
FLAVOR=dev
endif
TARGET=lib/main_$(FLAVOR).dart

get:
	flutter pub get

gen:
	dart run build_runner build --delete-conflicting-outputs

translate:
	dart run slang

android-release: android-apk-release

android-apk-release: 
	flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi --target $(TARGET)

android-aab-release:
	flutter build appbundle --target $(TARGET)

windows-release:
	flutter_distributor package --platform windows --targets exe --skip-clean --build-target $(TARGET)

linux-release:
	flutter_distributor package --platform linux --targets appimage --skip-clean --build-target $(TARGET)

macos-release:
	flutter_distributor package --platform macos --targets dmg --skip-clean --build-target $(TARGET)

ios-release: #not tested
	flutter_distributor package --platform ios --targets ipa --build-export-options-plist  ios/exportOptions.plist --build-target $(TARGET)


android-libs:
	mkdir -p $(ANDROID_OUT)
	curl -L $(CORE_URL)/$(CORE_NAME)-android.aar.gz | gunzip > $(ANDROID_OUT)/libcore.aar

android-apk-libs: android-libs
android-aab-libs: android-libs

windows-libs:
	mkdir -p $(DESKTOP_OUT)
	curl -L $(CORE_URL)/$(CORE_NAME)-windows-amd64.dll.gz | gunzip > $(DESKTOP_OUT)/libcore.dll

linux-libs:
	mkdir -p $(DESKTOP_OUT)
	curl -L $(CORE_URL)/$(CORE_NAME)-linux-amd64.so.gz | gunzip > $(DESKTOP_OUT)/libcore.so

macos-libs:
	mkdir -p $(DESKTOP_OUT)/ &&\
	curl -L $(CORE_URL)/$(CORE_NAME)-macos-universal.dylib.gz | gunzip > $(DESKTOP_OUT)/libcore.dylib

ios-libs: #not tested
	mkdir -p $(DESKTOP_OUT)/ &&\
	curl -L $(CORE_URL)/$(CORE_NAME)-ios-universal.xcframework.gz | gunzip > $(DESKTOP_OUT)/libcore.xcframework

get-geo-assets:
	curl -L https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db -o $(GEO_ASSETS_DIR)/geoip.db
	curl -L https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db -o $(GEO_ASSETS_DIR)/geosite.db

build-headers:
	make -C libcore -f Makefile headers && mv $(BINDIR)/$(CORE_NAME)-headers.h $(BINDIR)/libcore.h

build-android-libs:
	make -C libcore -f Makefile android && mv $(BINDIR)/$(CORE_NAME)-android.aar $(ANDROID_OUT)/libcore.aar

build-windows-libs:
	make -C libcore -f Makefile windows-amd64 && mv $(BINDIR)/$(CORE_NAME)-windows-amd64.dll $(DESKTOP_OUT)/libcore.dll

build-linux-libs:
	make -C libcore -f Makefile linux-amd64 && mv $(BINDIR)/$(CORE_NAME)-linux-amd64.dll $(DESKTOP_OUT)/libcore.so

build-macos-libs:
	make -C libcore -f Makefile macos-universal && mv $(BINDIR)/$(CORE_NAME)-macos-universal.dylib $(DESKTOP_OUT)/libcore.dylib

build-ios-libs: #not tested
	make -C libcore -f Makefile ios && mv $(BINDIR)/$(CORE_NAME)-ios.xcframework $(DESKTOP_OUT)/libcore.xcframework
