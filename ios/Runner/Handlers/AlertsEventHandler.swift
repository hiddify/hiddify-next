//
//  AlertEventHandler.swift
//  Runner
//
//  Created by GFWFighter on 10/24/23.
//

import Foundation
import Combine

public class AlertsEventHandler: NSObject, FlutterPlugin, FlutterStreamHandler {
    static let name = "\(Bundle.main.serviceIdentifier)/service.alerts"
    
    private var channel: FlutterEventChannel?
    
    private var cancellable: AnyCancellable?
    private var cancelBag: Set<AnyCancellable> = []
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AlertsEventHandler()
        instance.channel = FlutterEventChannel(name: Self.name, binaryMessenger: registrar.messenger())
        instance.channel?.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("[TLOG] handle start method \(AlertsEventHandler.name)")
        NSLog("[TLOG] handle start method \(AlertsEventHandler.name)")
        defer {
            print("[TLOG] handler end method \(AlertsEventHandler.name)")
            NSLog("[TLOG] handler end method \(AlertsEventHandler.name)")
        }
        VPNManager.shared.$alert.sink { [events] alert in
            var data = [
                "status": "Stopped",
                "alert": alert.alert?.rawValue,
                "message": alert.message,
            ]
            for key in data.keys {
                if data[key] == nil {
                    data.removeValue(forKey: key)
                }
            }
            events(data)
        }.store(in: &cancelBag)
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // cancellable?.cancel()
        return nil
    }
}
