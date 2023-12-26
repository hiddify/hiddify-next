//
//  LogsEventHandler.swift
//  Runner
//
//  Created by GFWFighter on 10/24/23.
//

import Foundation

public class LogsEventHandler: NSObject, FlutterPlugin, FlutterStreamHandler {
    static let name = "\(Bundle.main.serviceIdentifier)/service.logs"
    
    private var channel: FlutterEventChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = LogsEventHandler()
        instance.channel = FlutterEventChannel(name: Self.name, binaryMessenger: registrar.messenger())
        instance.channel?.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
