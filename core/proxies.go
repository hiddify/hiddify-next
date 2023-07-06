package main

import "C"
import (
	"context"
	"encoding/json"
	"log"
	"time"

	"github.com/Dreamacro/clash/adapter"
	"github.com/Dreamacro/clash/adapter/outboundgroup"
	"github.com/Dreamacro/clash/common/utils"
	"github.com/Dreamacro/clash/component/profile/cachefile"
	"github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/tunnel"
	bridge "hiddify.com/hiddify/bridge"
)

//export getProxies
func getProxies(port C.longlong) {
	proxies := tunnel.Proxies()
	data, err := json.Marshal(map[string]map[string]constant.Proxy{"proxies": proxies})
	if err != nil {
		bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
		return
	}
	bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: true, Data: string(data)})
}

//export updateProxy
func updateProxy(port C.longlong, selectorName *C.char, proxyName *C.char) {
	go func() {
		proxies := tunnel.Proxies()
		proxy := proxies[C.GoString(selectorName)]
		if proxy == nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: "proxy doesn't exist"})
			return
		}
		adapter_proxy := proxy.(*adapter.Proxy)
		selector, ok := adapter_proxy.ProxyAdapter.(*outboundgroup.Selector)
		if !ok {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: "not a selector"})
			return
		}
		if err := selector.Set(C.GoString(proxyName)); err != nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}
		cachefile.Cache().SetSelected(string(C.GoString(selectorName)), string(C.GoString(proxyName)))
		bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: true})
	}()
}

//export getProxyDelay
func getProxyDelay(port C.longlong, name *C.char, url *C.char, timeout C.long) {
	go func() {
		proxy := tunnel.Proxies()[C.GoString(name)]
		if proxy == nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: "proxy doesn't exist"})
			return
		}

		log.Printf("%s before ctx", proxy.Name())

		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(int64(timeout)))
		defer cancel()

		log.Printf("%s before expected status", proxy.Name())
		expectedStatus, err := utils.NewIntRanges[uint16]("200")
		if err != nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}
		delay, err := proxy.URLTest(ctx, C.GoString(url), expectedStatus, constant.ExtraHistory)
		if ctx.Err() != nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: ctx.Err().Error()})
			return
		}
		log.Printf("%s after ctx check", proxy.Name())
		if err != nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}

		log.Printf("%s before marshal", proxy.Name())
		data, err := json.Marshal(map[string]uint16{"delay": delay})
		if err != nil {
			bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: false, Message: err.Error()})
			return
		}

		bridge.SendResponseToPort(int64(port), &bridge.DartResponse{Success: true, Data: string(data)})
	}()
}
