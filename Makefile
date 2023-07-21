ANDROID_OUT=./android/app/src/main/jniLibs
DESKTOP_OUT=./core/bin
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
	flutter_distributor package --platform windows --targets exe

linux-release:
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

android-libs: 
	mkdir -p $(ANDROID_OUT)/x86_64  $(ANDROID_OUT)/arm64-v8a/ $(ANDROID_OUT)/armeabi-v7a/ &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify-clashlib-android-amd64.so.gz | gunzip > $(ANDROID_OUT)/x86_64/libclash.so &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify-clashlib-android-arm64.so.gz | gunzip > $(ANDROID_OUT)/arm64-v8a/libclash.so &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify-clashlib-android-arm.so.gz | gunzip > $(ANDROID_OUT)/armeabi-v7a/libclash.so

windows-libs:
	mkdir -p $(DESKTOP_OUT)/ &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-windows-amd64-cgo.dll.gz | gunzip > $(DESKTOP_OUT)/libclash.dll

linux-libs:
	mkdir -p $(DESKTOP_OUT)/ &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify_clashlib-windows-amd64-cgo.dll.gz | gunzip > $(DESKTOP_OUT)/libclash.dll


build-android-libs:
	cd core &&\
	mkdir -p .$(ANDROID_OUT)/x86_64/  .$(ANDROID_OUT)/arm64-v8a/ .$(ANDROID_OUT)/armeabi-v7a/ &&\
	make android-amd64 && mv bin/hiddify-clashlib-android-amd64.so .$(ANDROID_OUT)/x86_64/libclash.so &&\
	make android-arm && mv bin/hiddify-clashlib-android-arm.so .$(ANDROID_OUT)/armeabi-v7a/libclash.so &&\
	make android-arm64 && mv bin/hiddify-clashlib-android-arm64.so .$(ANDROID_OUT)/arm64-v8a/libclash.so

build-windows-libs:
	cd core &&\
	make windows-amd64 && mv bin/hiddify-clashlib-windows-amd64.dll bin/libclash.dll

build-linux-libs:
	cd core &&\
	make linux-amd64 && mv bin/hiddify-clashlib-linux-amd64.dll bin/libclash.dll

linux-libs:
	mkdir -p $(DESKTOP_OUT)/ &&\
	curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify-clashlib-linux-amd64.so.gz | gunzip > $(DESKTOP_OUT)/libclash.so
	#curl -L https://github.com/hiddify/hiddify-libclash/releases/latest/download/hiddify-clashlib-linux-386-so.gz | gunzip > $(DESKTOP_OUT)/libclash.so
