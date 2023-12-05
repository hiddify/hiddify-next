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
	rm -rf $(IOS_OUT)/libcore.xcframework
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



ios-temp-preapre: 
	flutter upgrade
	flutter pub upgrade
	make prepare platform=ios
	flutter build ios-framework
	cd ios
	pod install
	cd ..
	flutter run
	#Link the built App and Flutter and url_launcher_ios frameworks (or all created frameworks? i dunno, but i tried) from Release folder to Xcode project in Runner target’s Build Phases as Linked

	#change ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES  to $(inherited)

	#also add $(inherited) as 1st option to OTHER_LDFLAGS (Other Linker Flags)


	#add $(PROJECT_DIR)/Flutter/$(CONFIGURATION) to framework search path as 2nd

	#in Runner target go to Build Phases in Copy Bundle Resources section remove Runner.app

	# right click on Runner.xcodeproj click on Show Package Content open project.pbxproj  replace
	#Flutter/Release/App.xcframework
	#Flutter/Release/Flutter.xcframework
	# Flutter/Release/url_launcher_ios.xcframework
	# with
	# "Flutter/$(CONFIGURATION)/App.xcframework"
	# "Flutter/$(CONFIGURATION)/Flutter.xcframework"
	# "Flutter/$(CONFIGURATION)/url_launcher_ios.xcframework"
	# (if you added all frameworks, you should do this pattern for all of them too, you need this step to be able to run on simulators)

	# done remove	# GeneratedPluginRegistrant.h 	# GeneratedPluginRegistrant.m 	# from Runner folder and add newly generated ones from build/ios/framework folder to Xcode and also check the copy box

	# done in pod file 	# remove comment from line 2 and change it to 	# platform :ios, '12.1' 	# and add

	#	 target.build_configurations.each do |config|
	#	 config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.1'
	#	 end

	# before 1st ‘end’ in post_install function

	# add
	# -fcxx-modules
	# to
	# OTHER_CPLUSPLUSFLAGS
	# in Build Settings
	# as 1st option

	# flutter upgrade
	# flutter pub upgrade
	# cd ios
	# pod install

	# (note: i removed group and network extensions from targets to be able to build with free account)

	# now build
	# it will build (even on simulator)
	# but for some not known reason, it will not run for me on my device and will refuse to install on simulator, maybe because the removed extensions? i dunno
	# even now it can be an arsehole and return failed with exit code 1 so don’t panic