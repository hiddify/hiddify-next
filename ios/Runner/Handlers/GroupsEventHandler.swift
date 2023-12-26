//
//  GroupsEventHandler.swift
//  Runner
//
//  Created by GFWFighter on 10/24/23.
//

import Foundation
import Libcore

struct SBItem: Codable {
    let tag: String
    let type: String
    let urlTestDelay: Int
    
    enum CodingKeys: String, CodingKey {
        case tag
        case type
        case urlTestDelay = "url-test-delay"
    }
}

struct SBGroup: Codable {
    let tag: String
    let type: String
    let selected: String
    let items: [SBItem]
}

public class GroupsEventHandler: NSObject, FlutterPlugin, FlutterStreamHandler, LibboxCommandClientHandlerProtocol {
    
    static let name = "\(Bundle.main.serviceIdentifier)/groups"
    
    private var channel: FlutterEventChannel?
    
    private var commandClient: LibboxCommandClient?
    private var events: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = GroupsEventHandler()
        instance.channel = FlutterEventChannel(name: Self.name, binaryMessenger: registrar.messenger())
        instance.channel?.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        FileManager.default.changeCurrentDirectoryPath(FilePath.sharedDirectory.path)
        self.events = events
        let opts = LibboxCommandClientOptions()
        opts.command = LibboxCommandGroup
        opts.statusInterval = 3000
        commandClient = LibboxCommandClient(self, options: opts)
        try? commandClient?.connect()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        try? commandClient?.disconnect()
        return nil
    }
    
    public func writeGroups(_ message: LibboxOutboundGroupIteratorProtocol?) {
        guard let message else { return }
        var groups = [SBGroup]()
        while message.hasNext() {
            let group = message.next()!
            var items = [SBItem]()
            var groupItems = group.getItems()
            while groupItems?.hasNext() ?? false {
                let item = groupItems?.next()!
                items.append(SBItem(tag: item!.tag, type: item!.type, urlTestDelay: Int(item!.urlTestDelay)))
            }
            groups.append(.init(tag: group.tag, type: group.type, selected: group.selected, items: items))
        }
        if 
            let groups = try? JSONEncoder().encode(groups),
            let groups = String(data: groups, encoding: .utf8)
        {
            DispatchQueue.main.async { [events = self.events, groups] () in
                events?(groups)
            }
        }
    }
}

extension GroupsEventHandler {
    public func clearLog() {}
    public func connected() {}
    public func disconnected(_ message: String?) {}
    public func initializeClashMode(_ modeList: LibboxStringIteratorProtocol?, currentMode: String?) {}
    public func updateClashMode(_ newMode: String?) {}
    public func writeLog(_ message: String?) {}
    public func writeStatus(_ message: LibboxStatusMessage?) {}
}
