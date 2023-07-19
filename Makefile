ANDROID_OUT=../android/app/src/main/jniLibs
NDK_BIN=$(ANDROID_HOME)/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin
GOBUILD=CGO_ENABLED=1 go build -trimpath -tags with_gvisor,with_lwip -ldflags="-w -s" -buildmode=c-shared

get:
	flutter pub get
gen:
	dart run build_runner build --delete-conflicting-outputs
translate:
	dart run slang


android-release:
    flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi

windows-release:
	dart pub global activate flutter_distributor
	flutter_distributor package --platform windows --targets exe
	

linux-release:
	dart pub global activate flutter_distributor
	which locate
	if [ $? =! 0 ];then 
		sudo apt install locate
	fi
	which appimagetool
	if [ $? =! 0 ];then 
		wget -O appimagetool "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
		chmod +x appimagetool
		mv appimagetool /usr/local/bin/
	fi
	flutter_distributor package --platform linux --targets appimage

macos-release:
	dart pub global activate flutter_distributor
	npm install -g appdmg
	flutter_distributor package --platform macos --targets dmg

ios-release:
	flutter_distributor package --platform ios --targets ipa --build-export-options-plist  ios/exportOptions.plist











android-libs: android-x64 android-arm android-arm64
android-x64:
	cd core && env GOOS=android GOARCH=amd64 CC=$(NDK_BIN)/x86_64-linux-android21-clang $(GOBUILD) -o $(ANDROID_OUT)/x86_64/libclash.so # building android x64 clash libs

android-arm:
	cd core && env GOOS=android GOARCH=arm GOARM=7 CC=$(NDK_BIN)/armv7a-linux-androideabi21-clang $(GOBUILD) -o $(ANDROID_OUT)/armeabi-v7a/libclash.so # building android arm clash libs

android-arm64:
	cd core && env GOOS=android GOARCH=arm64 CC=$(NDK_BIN)/aarch64-linux-android21-clang $(GOBUILD) -o $(ANDROID_OUT)/arm64-v8a/libclash.so # building android arm64 clash libs

windows-libs:
	cd core && env GOOS=windows GOARCH=amd64 CC=x86_64-w64-mingw32-gcc $(GOBUILD) -o dist/libclash.dll # building windows clash libs





