import Foundation
import Combine

public class LogsEventHandler: NSObject, FlutterPlugin, FlutterStreamHandler {
    static let name = "\(Bundle.main.serviceIdentifier)/service.logs"
    
    private var channel: FlutterEventChannel?
    private var cancellable: AnyCancellable?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = LogsEventHandler()
        instance.channel = FlutterEventChannel(name: Self.name, binaryMessenger: registrar.messenger())
        instance.channel?.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        VPNManager.shared.logClient?.connect()
        cancellable = VPNManager.shared.logClient?.$logList.sink { [events] logsList in
            events(logsList)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        cancellable?.cancel()
        return nil
    }
}
