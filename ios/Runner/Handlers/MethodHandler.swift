//
//  MethodHandler.swift
//  Runner
//
//  Created by GFWFighter on 10/23/23.
//

import Flutter
import Combine
import Libcore

public class MethodHandler: NSObject, FlutterPlugin {
    
    private var cancelBag: Set<AnyCancellable> = []
    
    public static let name = "\(Bundle.main.serviceIdentifier)/method"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Self.name, binaryMessenger: registrar.messenger())
        let instance = MethodHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel	
    }
    
    private var channel: FlutterMethodChannel?
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "parse_config":
            result(parseConfig(args: call.arguments))
        case "change_config_options":
            result(changeConfigOptions(args: call.arguments))
        case "setup":
            Task { [unowned self] in
                let res = await setup(args: call.arguments)
                await MainActor.run {
                    result(res)
                }
            }
        case "start":
            Task { [unowned self] in
                let res = await start(args: call.arguments)
                await MainActor.run {
                    result(res)
                }
            }
        case "restart":
            Task { [unowned self] in
                let res = await restart(args: call.arguments)
                await MainActor.run {
                    result(res)
                }
            }
        case "stop":
            result(stop())
        case "url_test":
            result(urlTest(args: call.arguments))
        case "select_outbound":
            result(selectOutbound(args: call.arguments))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func parseConfig(args: Any?) -> String {
        var error: NSError?
        guard
            let args = args as? [String:Any?],
            let path = args["path"] as? String,
            let tempPath = args["tempPath"] as? String,
            let debug = (args["debug"] as? NSNumber)?.boolValue
        else {
            return "bad method format"
        }
        let res = MobileParse(path, tempPath, debug, &error)
        if let error {
            return error.localizedDescription
        }
        return ""
    }
    
    public func changeConfigOptions(args: Any?) -> Bool {
        guard let options = args as? String else {
            return false
        }
        VPNConfig.shared.configOptions = options
        return true
    }
    
    public func setup(args: Any?) async -> Bool {
        do {
            try await VPNManager.shared.setup()
        } catch {
            return false
        }
        return true
    }
    
    public func start(args: Any?) async -> Bool {
        guard
            let args = args as? [String:Any?],
            let path = args["path"] as? String
        else {
            return false
        }
        VPNConfig.shared.activeConfigPath = path
        var error: NSError?
        let config = MobileBuildConfig(path, VPNConfig.shared.configOptions, &error)
        if let error {
            return false
        }
        do {
            try await VPNManager.shared.setup()
            try await VPNManager.shared.connect(with: config, disableMemoryLimit: VPNConfig.shared.disableMemoryLimit)
        } catch {
            return false
        }
        return true
    }
    
    public func stop() -> Bool {
        VPNManager.shared.disconnect()
        return true
    }
    
    private func waitForStop() -> Future<Void, Never> {
        return Future { promise in
            var cancellable: AnyCancellable? = nil
            cancellable = VPNManager.shared.$state
                .filter { $0 == .disconnected }
                .first()
                .delay(for: 0.5, scheduler: RunLoop.current)
                .sink(receiveValue: { _ in
                    promise(.success(()))
                    cancellable?.cancel()
                })
        }
    }
    
    public func restart(args: Any?) async -> Bool {
        guard
            let args = args as? [String:Any?],
            let path = args["path"] as? String
        else {
            return false
        }
        VPNConfig.shared.activeConfigPath = path
        VPNManager.shared.disconnect()
        await waitForStop().value
        var error: NSError?
        let config = MobileBuildConfig(path, VPNConfig.shared.configOptions, &error)
        if let error {
            return false
        }
        do {
            try await VPNManager.shared.setup()
            try await VPNManager.shared.connect(with: config, disableMemoryLimit: VPNConfig.shared.disableMemoryLimit)
        } catch {
            return false
        }
        return true
    }
    
    public func selectOutbound(args: Any?) -> Bool {
        guard
            let args = args as? [String:Any?],
            let group = args["groupTag"] as? String,
            let outbound = args["outboundTag"] as? String
        else {
            return false
        }
        FileManager.default.changeCurrentDirectoryPath(FilePath.sharedDirectory.path)
        do {
            try LibboxNewStandaloneCommandClient()?.selectOutbound(group, outboundTag: outbound)
        } catch {
            return false
        }
        return true
    }
    
    public func urlTest(args: Any?) -> Bool {
        guard
            let args = args as? [String:Any?]
        else {
            return false
        }
        let group = args["groupTag"] as? String
        FileManager.default.changeCurrentDirectoryPath(FilePath.sharedDirectory.path)
        do {
            try LibboxNewStandaloneCommandClient()?.urlTest(group)
        } catch {
            return false
        }
        return true
    }
}
