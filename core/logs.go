package main

import "C"
import (
	"encoding/json"
	"fmt"

	"github.com/Dreamacro/clash/log"
	bridge "hiddify.com/hiddify/bridge"
)

var logSubscriber <-chan log.Event

type Log struct {
	Type    string `json:"type"`
	Payload string `json:"payload"`
}

//export startLog
func startLog(port C.longlong, levelStr *C.char) {
	levelTxt := C.GoString(levelStr)
	if levelTxt == "" {
		levelTxt = "info"
	}
	level := log.LogLevelMapping[levelTxt]
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
	logSubscriber = log.Subscribe()
	go func() {
		for elem := range logSubscriber {
			if elem.LogLevel < level {
				continue
			}
			data, err := json.Marshal(Log{
				Type:    elem.Type(),
				Payload: elem.Payload,
			})
			if err != nil {
				fmt.Println("Error:", err)
			}
			bridge.SendStringToPort(int64(port), string(data))
		}
	}()
	fmt.Println("[GO] subscribe logger on dart bridge port", int64(port))
}

//export stopLog
func stopLog() {
	if logSubscriber != nil {
		log.UnSubscribe(logSubscriber)
		logSubscriber = nil
	}
}
