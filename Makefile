include dependencies.properties

BINDIR=./libcore/bin
ANDROID_OUT=./android/app/libs
IOS_OUT=./ios/Frameworks
DESKTOP_OUT=./libcore/bin
GEO_ASSETS_DIR=./assets/core

CORE_PRODUCT_NAME=hiddify-core
CORE_NAME=$(CORE_PRODUCT_NAME)
SRV_NAME=hiddify-service
ifeq ($(CHANNEL),prod)
CORE_URL=https://github.com/hiddify/hiddify-next-core/releases/download/v$(core.version)
else
CORE_URL=https://github.com/hiddify/hiddify-next-core/releases/download/draft
endif

ifeq ($(CHANNEL),prod)
TARGET=lib/main_prod.dart
else
TARGET=lib/main.dart
endif

BUILD_ARGS=--dart-define sentry_dsn=$(SENTRY_DSN)
DISTRIBUTOR_ARGS=--skip-clean --build-target $(TARGET) --build-dart-define sentry_dsn=$(SENTRY_DSN)

get:
	flutter pub get

gen:
	dart run build_runner build --delete-conflicting-outputs

translate:
	dart run slang

prepare: get-geo-assets get gen translate
	@echo "Available platforms:"
	@echo "android"
	@echo "windows"
	@echo "linux"
	@echo "macos"
	@echo "ios"
	if [ -z "$$platform" ]; then \
		read -p "run make prepare platform=ios or Enter platform name: " choice; \
	else \
		choice=$$platform; \
	fi; \
	make $$choice-libs

sync_translate:
	cd .github && bash sync_translate.sh
	make translate

android-release: android-apk-release

android-apk-release:
	flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi --target $(TARGET) $(BUILD_ARGS)
	ls -R build/app/outputs

android-aab-release:
	flutter build appbundle --target $(TARGET) $(BUILD_ARGS) --dart-define release=google-play
	ls -R build/app/outputs

windows-release:
	flutter_distributor package --platform windows --targets exe $(DISTRIBUTOR_ARGS)

linux-release: linux-appimage-release linux-deb-release linux-rpm-release

linux-appimage-release:
	flutter_distributor package --platform linux --targets appimage $(DISTRIBUTOR_ARGS)
linux-deb-release:
	flutter_distributor package --platform linux --targets deb $(DISTRIBUTOR_ARGS)
linux-rpm-release:
	flutter_distributor package --platform linux --targets rpm $(DISTRIBUTOR_ARGS)


macos-release:
	flutter_distributor package --platform macos --targets dmg $(DISTRIBUTOR_ARGS)

ios-release: #not tested
	flutter_distributor package --platform ios --targets ipa --build-export-options-plist  ios/exportOptions.plist $(DISTRIBUTOR_ARGS)

android-libs:
	mkdir -p $(ANDROID_OUT)
	curl -L $(CORE_URL)/$(CORE_NAME)-android.tar.gz | tar xz -C $(ANDROID_OUT)/

android-apk-libs: android-libs
android-aab-libs: android-libs

windows-libs:
	mkdir -p $(DESKTOP_OUT)
	curl -L $(CORE_URL)/$(CORE_NAME)-windows-amd64.tar.gz | tar xz -C $(DESKTOP_OUT)/

linux-libs:
	mkdir -p $(DESKTOP_OUT)
	curl -L $(CORE_URL)/$(CORE_NAME)-linux-amd64.tar.gz | tar xz -C $(DESKTOP_OUT)/


linux-deb-libs:linux-libs
linux-rpm-libs:linux-libs
linux-appimage-libs:linux-libs

macos-libs:
	mkdir -p $(DESKTOP_OUT)/ &&\
	curl -L $(CORE_URL)/$(CORE_NAME)-macos-universal.tar.gz | tar xz -C $(DESKTOP_OUT)/

ios-libs: #not tested
	mkdir -p $(DESKTOP_OUT)/ && \
	rm -rf $(IOS_OUT)/Libcore.xcframework && \
	curl -L $(CORE_URL)/$(CORE_NAME)-ios.tar.gz | tar xz -C "$(IOS_OUT)" 

get-geo-assets:
	curl -L https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db -o $(GEO_ASSETS_DIR)/geoip.db
	curl -L https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db -o $(GEO_ASSETS_DIR)/geosite.db

build-headers:
	make -C libcore -f Makefile headers && mv $(BINDIR)/$(CORE_NAME)-headers.h $(BINDIR)/libcore.h

build-android-libs:
	make -C libcore -f Makefile android 
	mv $(BINDIR)/$(CORE_NAME).aar $(ANDROID_OUT)/

build-windows-libs:
	make -C libcore -f Makefile windows-amd64
	mv $(BINDIR)/$(CORE_NAME).dll $(DESKTOP_OUT)/
	mv $(BINDIR)/$(SRV_NAME) $(DESKTOP_OUT)/

build-linux-libs:
	make -C libcore -f Makefile linux-amd64 
	mv $(BINDIR)/$(CORE_NAME).so $(DESKTOP_OUT)/
	mv $(BINDIR)/$(SRV_NAME) $(DESKTOP_OUT)/

build-macos-libs:
	make -C libcore -f Makefile macos-universal
	mv $(BINDIR)/$(CORE_NAME).dylib $(DESKTOP_OUT)/
	mv $(BINDIR)/$(SRV_NAME) $(DESKTOP_OUT)/

build-ios-libs: 
	rm -rf $(IOS_OUT)/Libcore.xcframework && \
	make -C libcore -f Makefile ios  && \
	mv $(BINDIR)/$(CORE_NAME)-ios.xcframework $(IOS_OUT)/Libcore.xcframework

release: # Create a new tag for release.
 	
	@echo "previous version was $$(git describe --tags $$(git rev-list --tags --max-count=1))"
	@echo "WARNING: This operation will creates version tag and push to github"
	@bash -c '\
	[ "404" == $$(curl -I -s -w "%{http_code}" https://github.com/hiddify/hiddify-next-core/releases/download/v$(core.version)/hiddify-libcore-windows-amd64.h.gz -o /dev/null) ]&&{ echo "Core Not Found"; exit 1 ; };\
	cversion_string=`grep -e "^version:" pubspec.yaml | cut -d: -f2-`; \
	cstr_version=`echo "$${cversion_string}" | sed -n "s/[ ]*\\([0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\)+.*/\\1/p"`; \
	cbuild_number=`echo "$${cversion_string}" | sed -n "s/.*+\\([0-9]\\+\\)/\\1/p"`; \
	echo "Current Version Name:$${cstr_version}   Build Number:$${cbuild_number}";\
	read -p "new Version? (provide the next x.y.z semver) : " TAG && \
	echo $$TAG &&\
	[[ "$$TAG" =~ ^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}(\.dev)?$$ ]] || { echo "Incorrect tag. e.g., 1.2.3 or 1.2.3.dev"; exit 1; } && \
	IFS="." read -r -a VERSION_ARRAY <<< "$$TAG" && \
	VERSION_STR="$${VERSION_ARRAY[0]}.$${VERSION_ARRAY[1]}.$${VERSION_ARRAY[2]}" && \
	BUILD_NUMBER=$$(( $${VERSION_ARRAY[0]} * 10000 + $${VERSION_ARRAY[1]} * 100 + $${VERSION_ARRAY[2]} )) && \
	echo "version: $${VERSION_STR}+$${BUILD_NUMBER}" && \
	sed -i "s/^version: .*/version: $${VERSION_STR}\+$${BUILD_NUMBER}/g" pubspec.yaml && \
	sed -i "s/CURRENT_PROJECT_VERSION = $${cbuild_number}/CURRENT_PROJECT_VERSION = $${BUILD_NUMBER}/g" ios/Runner.xcodeproj/project.pbxproj && \
	sed -i "s/MARKETING_VERSION = $${cstr_version}/MARKETING_VERSION = $${VERSION_STR}/g" ios/Runner.xcodeproj/project.pbxproj && \
	git add ios/Runner.xcodeproj/project.pbxproj pubspec.yaml&& \
	git commit -m "release: version $${TAG}" && \
	echo "creating git tag : v$${TAG}" && \
	git push && \
	git tag v$${TAG} && \
	git push -u origin HEAD --tags && \
	echo "Github Actions will detect the new tag and release the new version."'



ios-temp-prepare: 
	make prepare platform=ios
	flutter build ios-framework
	cd ios
	pod install
	