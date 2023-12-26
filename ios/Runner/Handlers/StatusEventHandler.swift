//
//  StatusEventHandler.swift
//  Runner
//
//  Created by GFWFighter on 10/24/23.
//

import Foundation
import Combine

public class StatusEventHandler: NSObject, FlutterPlugin, FlutterStreamHandler {
    static let name = "\(Bundle.main.serviceIdentifier)/service.status"
    
    private var channel: FlutterEventChannel?
    
    private var cancellable: AnyCancellable?
    private var cancelBag: Set<AnyCancellable> = []
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = StatusEventHandler()
        instance.channel = FlutterEventChannel(name: Self.name, binaryMessenger: registrar.messenger())
        instance.channel?.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("[TLOG] handle start method \(StatusEventHandler.name)")
        NSLog("[TLOG] handle start method \(StatusEventHandler.name)")
        defer {
            print("[TLOG] handler end method \(StatusEventHandler.name)")
            NSLog("[TLOG] handler end method \(StatusEventHandler.name)")
        }
        VPNManager.shared.$state.sink { [events] status in
            switch status {
            case .reasserting, .connecting:
                events(["status": "Starting"])
            case .connected:
                events(["status": "Started"])
            case .disconnecting:
                events(["status": "Stopping"])
            case .disconnected, .invalid:
                events(["status": "Stopped"])
            @unknown default:
                events(["status": "Stopped"])
            }
        }.store(in: &cancelBag)
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // cancellable?.cancel()
        return nil
    }
}
