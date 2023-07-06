package main

import "C"
import (
	"encoding/json"

	"github.com/Dreamacro/clash/tunnel/statistic"
	bridge "hiddify.com/hiddify/bridge"
)

type Traffic struct {
	Up   int64 `json:"up"`
	Down int64 `json:"down"`
}

//export getTraffic
func getTraffic(port C.longlong) {
	go func() {
		t := statistic.DefaultManager
		up, down := t.Now()
		traffic, err := json.Marshal(Traffic{
			Up:   up,
			Down: down,
		})

		if err != nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}
		bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: true, Data: string(traffic)})
	}()
}
