import Foundation
import Combine
import Libcore

class LogsEventHandler: NSObject, FlutterPlugin, FlutterStreamHandler, LibboxCommandClientHandlerProtocol {
    static let name = "\(Bundle.main.serviceIdentifier)/service.logs"
    
    private var channel: FlutterEventChannel?

    private var commandClient: LibboxCommandClient?
    private var events: FlutterEventSink?
    private var maxLines: Int
    private var logList: [String] = []

    private var lock: NSLock = NSLock()

    public static func register(with registrar: FlutterPluginRegistrar) {
          let instance = LogsEventHandler()
          instance.channel = FlutterEventChannel(name: Self.name, binaryMessenger: registrar.messenger())
          instance.channel?.setStreamHandler(instance)
    }

    init(maxLines: Int = 32) {
        self.maxLines = maxLines
        super.init()
        let opts = LibboxCommandClientOptions()
        opts.command = LibboxCommandLog
        opts.statusInterval = Int64(2 * NSEC_PER_SEC)
        commandClient = LibboxCommandClient(self, options: opts)
        try? commandClient?.connect()
    }
    
    deinit {
        try? commandClient?.disconnect()
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        events(logList)
        self.events = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        events = nil
        return nil
    }

    func writeLog(_ message: String?) {
        guard let message else {
            return
        }
        lock.withLock { [self] in
            if logList.count > maxLines {
                logList.removeFirst()
            }
            logList.append(message)
            DispatchQueue.main.async { [self] () in
                events?(logList)
            }
        }
    }
}

extension LogsEventHandler {
    public func clearLog() {}
    public func connected() {}
    public func disconnected(_ message: String?) {}
    public func initializeClashMode(_ modeList: LibboxStringIteratorProtocol?, currentMode: String?) {}
    public func updateClashMode(_ newMode: String?) {}
    public func writeGroups(_ message: LibboxOutboundGroupIteratorProtocol?) {}
    public func writeStatus(_ message: LibboxStatusMessage?) {}
}
