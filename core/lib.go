package main

/*
#include "stdint.h"
*/
import "C"
import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"unsafe"

	"github.com/Dreamacro/clash/config"
	"github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/hub"
	bridge "hiddify.com/hiddify/bridge"
)

var options []hub.Option

//export initNativeDartBridge
func initNativeDartBridge(api unsafe.Pointer) {
	bridge.InitDartApi(api)
}

//export setOptions
func setOptions(port C.longlong, dir *C.char, configPath *C.char) {
	go func() {
		dir := C.GoString(dir)
		info, err := os.Stat(dir)
		if err != nil {
			log.Printf("[core] dir %s: %+v\n", dir, err)
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}
		if !info.IsDir() {
			log.Printf("[core] %s is not a directory\n", dir)
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: "not directory"})
			return
		}
		constant.SetHomeDir(dir)

		path := C.GoString(configPath)
		if !filepath.IsAbs(path) {
			path = filepath.Join(dir, path)
		}
		constant.SetConfig(path)

		bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: true})
	}()
}

//export start
func start(port C.longlong) {
	go func() {
		if err := config.Init(constant.Path.HomeDir()); err != nil {
			log.Printf("[core] start error: init error: %+v\n", err)
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}
		err := hub.Parse(options...)
		if err != nil {
			log.Printf("[core] start error: %+v\n", err)
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}
		bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: true})
	}()

}

func main() {
	fmt.Println("hello from clash native lib!")
}
