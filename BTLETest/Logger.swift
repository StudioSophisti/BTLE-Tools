//
//  Logger.swift
//  BTLETools
//
//  Created by Tijn Kooijmans on 09/11/2016.
//
//

import Foundation
import CoreBluetooth

@objc enum Event: Int {
    case Connected
    case Disconnected
    case DataReceived
    case DataSend
    
    func toString() -> String {
        switch self {
        case .Connected:
            return "connected"
        case .Disconnected:
            return "disconnected"
        case .DataReceived:
            return "received"
        case .DataSend:
            return "send"
        }
    }
}

@objc class Logger: NSObject {
    
    static let shared = Logger()
    
    var log = ""
    
    var headers = "timestamp,device,event,service,characteristic,hexdata,asciidata\n"
    
    let timeFormatter = DateFormatter()
    
    var logChangedCallback: (() -> ())?
    
    override init() {
        super.init()
        
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
    }
    
    public func append(device: CBPeripheral, event: Event, service: CBService? = nil, characteristic: CBCharacteristic? = nil, data: NSData? = nil) {
        var name = "no name"
        if let n = device.name { name = n }
        if service == nil {
            log = "\(timeFormatter.string(from: Date())),\(name),\(event.toString())\n" + log
            
        } else if characteristic == nil {
            log = "\(timeFormatter.string(from: Date())),\(name),\(event.toString()),\(service!.serviceName()!)\n" + log
            
        } else if data == nil {
            log = "\(timeFormatter.string(from: Date())),\(name),\(event.toString()),\(service!.serviceName()!),\(characteristic!.characteristicName()!)\n" + log
            
        } else {
            log = "\(timeFormatter.string(from: Date())),\(name),\(event.toString()),\(service!.serviceName()!),\(characteristic!.characteristicName()!),\(data!.hexString()!),\"\(data!.asciiString()!)\"\n" + log
            
        }
        
        logChangedCallback?()
    }
    
    func clear() {
        log = ""
        
        logChangedCallback?()
    }
    
    func export() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(dateFormatter.string(from: Date()) + ".csv")       
        try? (headers.write(to: url, atomically: true, encoding: .ascii))
        if let fileHandle = try? FileHandle(forWritingTo: url) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(log.data(using: .ascii, allowLossyConversion: true)!)
            fileHandle.closeFile()
        }
        return url
    }
}
