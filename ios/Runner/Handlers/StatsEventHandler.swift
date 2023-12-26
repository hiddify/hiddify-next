//
//  StatsEventHandler.swift
//  Runner
//
//  Created by Hiddify on 12/27/23.
//

import Foundation
import Flutter
import Libcore

public class StatsEventHandler: NSObject, FlutterPlugin, FlutterStreamHandler, LibboxCommandClientHandlerProtocol {
    static let name = "\(Bundle.main.serviceIdentifier)/stats"
    
    private var channel: FlutterEventChannel?
    
    private var commandClient: LibboxCommandClient?
    private var events: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = StatsEventHandler()
        instance.channel = FlutterEventChannel(name: Self.name, binaryMessenger: registrar.messenger())
        instance.channel?.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        FileManager.default.changeCurrentDirectoryPath(FilePath.sharedDirectory.path)
        self.events = events
        let opts = LibboxCommandClientOptions()
        opts.command = LibboxCommandStatus
        opts.statusInterval = 300
        commandClient = LibboxCommandClient(self, options: opts)
        try? commandClient?.connect()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        try? commandClient?.disconnect()
        return nil
    }
    
    public func writeStatus(_ message: LibboxStatusMessage?) {
        guard 
            let message
        else { return }
        let data = [
            "connections-in": message.connectionsIn,
            "connections-out": message.connectionsOut,
            "uplink": message.uplink,
            "downlink": message.downlink,
            "uplink-total": message.uplinkTotal,
            "downlink-total": message.downlinkTotal
        ] as [String:Any]
        guard
            let json = try? JSONSerialization.data(withJSONObject: data),
            let json = String(data: json, encoding: .utf8)
        else { return }
        events?(json)
    }
}

extension StatsEventHandler {
    public func clearLog() {}
    public func connected() {}
    public func disconnected(_ message: String?) {}
    public func initializeClashMode(_ modeList: LibboxStringIteratorProtocol?, currentMode: String?) {}
    public func updateClashMode(_ newMode: String?) {}
    public func writeGroups(_ message: LibboxOutboundGroupIteratorProtocol?) {}
    public func writeLog(_ message: String?) {}
}
