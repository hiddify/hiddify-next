ANDROID_OUT=./android/app/src/main/jniLibs
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
	dart pub global activate flutter_distributor && \
	flutter_distributor package --platform windows --targets exe

linux-release:
	dart pub global activate flutter_distributor && \
	which locate && \
	if [ $$? != 0 ]; then \
		sudo apt install locate; \
	fi && \
	which appimagetool && \
	if [ $$? != 0 ]; then \
		wget -O appimagetool "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" && \
		chmod +x appimagetool && \
		mv appimagetool /usr/local/bin/; \
	fi && \
	flutter_distributor package --platform linux --targets appimage

macos-release:
	dart pub global activate flutter_distributor && \
	npm install -g appdmg && \
	flutter_distributor package --platform macos --targets dmg

ios-release:
	flutter_distributor package --platform ios --targets ipa --build-export-options-plist ios/exportOptions.plist

android-libs: 
	mkdir -p $(ANDROID_OUT)/x86_64  $(ANDROID_OUT)/arm64-v8a/ armeabi-v7a/ &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-linux-amd64-cgo.so.gz | gunzip >  $(ANDROID_OUT)/x86_64/hiddify_libclash.so &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-android-arm64-cgo.so.gz | gunzip >$(ANDROID_OUT)/arm64-v8a/hiddify_libclash.so &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-linux-armv7-cgo.so.gz | gunzip >$(ANDROID_OUT)/armeabi-v7a/hiddify_libclash.so 

windows-libs:
	mkdir ./dist/&&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-windows-amd64-cgo.dll.gz | gunzip >./dist/hiddify_libclash_x64.dll &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-windows-386-cgo.dll.gz | gunzip >./dist/hiddify_libclash_x86.dll 

linux-libs:
	mkdir ./dist/&&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-linux-amd64-cgo.so.gz | gunzip > ./dist/hiddify_libclash_x64.so &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-linux-386-cgo.so.gz | gunzip > ./dist/hiddify_libclash_x86.so

macos-libs:
	mkdir -p ./macos/Frameworks &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-darwin-amd64-cgo.dylib.gz | gunzip > ./macos/Frameworks/hiddify_libclash_x64.dylib &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-darwin-arm64-cgo.dylib.gz | gunzip > ./macos/Frameworks/hiddify_libclash_arm64.dylib
