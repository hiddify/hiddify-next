include dependencies.properties

BINDIR=./libcore/bin
ANDROID_OUT=./android/app/libs
IOS_OUT=./libcore/bin
DESKTOP_OUT=./libcore/bin
GEO_ASSETS_DIR=./assets/core

CORE_PRODUCT_NAME=libcore
CORE_NAME=hiddify-$(CORE_PRODUCT_NAME)
ifeq ($(CHANNEL),prod)
CORE_URL=https://github.com/hiddify/hiddify-next-core/releases/download/v$(core.version)
else
CORE_URL=https://github.com/hiddify/hiddify-next-core/releases/download/draft
endif

ifeq ($(CHANNEL),prod)
FLAVOR=prod
else
FLAVOR=dev
endif

TARGET=lib/main_$(FLAVOR).dart
BUILD_ARGS=--dart-define sentry_dsn=$(SENTRY_DSN)
DISTRIBUTOR_ARGS=--skip-clean --build-target $(TARGET) --build-dart-define sentry_dsn=$(SENTRY_DSN)

get:
	flutter pub get

gen:
	dart run build_runner build --delete-conflicting-outputs

translate:
	dart run slang

prepare: get-geo-assets get gen translate
	@echo "Select a platform:"
	@echo "1. Android"
	@echo "2. Windows"
	@echo "3. Linux"
	@echo "4. macOS"
	@echo "5. iOS"
	@read -p "Enter your choice (1 to 5): " choice; \
	case $$choice in \
		1) make android-libs ;; \
		2) make windows-libs ;; \
		3) make linux-libs ;; \
		4) make macos-libs ;; \
		5) make ios-libs ;; \
		*) echo "Invalid choice. Please select 1 to 5." ;; \
	esac

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

linux-release:
	flutter_distributor package --platform linux --targets appimage $(DISTRIBUTOR_ARGS)

macos-release:
	flutter_distributor package --platform macos --targets dmg $(DISTRIBUTOR_ARGS)

ios-release: #not tested
	flutter_distributor package --platform ios --targets ipa --build-export-options-plist  ios/exportOptions.plist $(DISTRIBUTOR_ARGS)

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
	curl -L $(CORE_URL)/$(CORE_NAME)-ios.xcframework.tar.gz | tar xz -C "$(IOS_OUT)" && \
	mv $(IOS_OUT)/$(CORE_NAME)-ios.xcframework $(IOS_OUT)/libcore.xcframework

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
	make -C libcore -f Makefile linux-amd64 && mv $(BINDIR)/$(CORE_NAME)-linux-amd64.so $(DESKTOP_OUT)/libcore.so

build-macos-libs:
	make -C libcore -f Makefile macos-universal && mv $(BINDIR)/$(CORE_NAME)-macos-universal.dylib $(DESKTOP_OUT)/libcore.dylib

build-ios-libs: 
	make -C libcore -f Makefile ios  && mv $(BINDIR)/$(CORE_NAME)-ios.xcframework $(IOS_OUT)/libcore.xcframework

release: # Create a new tag for release.
	@echo "previous version was $$(git describe --tags $$(git rev-list --tags --max-count=1))"
	@echo "WARNING: This operation will creates version tag and push to github"
	@bash -c '\
	read -p "Version? (provide the next x.y.z semver) : " TAG && \
	echo $$TAG &&\
	[[ "$$TAG" =~ ^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}(\.dev)?$$ ]] || { echo "Incorrect tag. e.g., 1.2.3 or 1.2.3.dev"; exit 1; } && \
	IFS="." read -r -a VERSION_ARRAY <<< "$$TAG" && \
	VERSION_STR="$${VERSION_ARRAY[0]}.$${VERSION_ARRAY[1]}.$${VERSION_ARRAY[2]}" && \
	BUILD_NUMBER=$$(( $${VERSION_ARRAY[0]} * 10000 + $${VERSION_ARRAY[1]} * 100 + $${VERSION_ARRAY[2]} )) && \
	echo "version: $${VERSION_STR}+$${BUILD_NUMBER}" && \
	sed -i "s/^version: .*/version: $${VERSION_STR}\+$${BUILD_NUMBER}/g" pubspec.yaml && \
	git tag $${TAG} > /dev/null && \
	git tag -d $${TAG} > /dev/null && \
	git add pubspec.yaml CHANGELOG.md && \
	git commit -m "release: version $${TAG}" && \
	echo "creating git tag : v$${TAG}" && \
	git tag v$${TAG} && \
	git push -u origin HEAD --tags && \
	echo "Github Actions will detect the new tag and release the new version."'
