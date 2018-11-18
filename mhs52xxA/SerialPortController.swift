//
//  SerialPortController.swift
//  mhs52xxA
//
//  Created by Kevin Peck on 2018-11-15.
//  Copyright © 2018 House of Kevin Peck. All rights reserved.
//

import Foundation
import ORSSerial

class SerialPortController : NSObject, ORSSerialPortDelegate {
    var serialPort: ORSSerialPort?
    var cmdPrefix: String = ""
    var cmdSuffix: String = ""
    var commandsPending: Int = 0

    convenience init(portPath: String, portBaudRate: NSNumber, cmdPrefix: String = ":", cmdSuffix: String = "\n") {
        self.init()
        self.serialPort = ORSSerialPort(path: portPath)
        self.serialPort?.baudRate = portBaudRate
        self.serialPort?.delegate = self
        self.cmdPrefix = cmdPrefix
        self.cmdSuffix = cmdSuffix
        self.serialPort?.open()
    }
        
    func sendCommand(command: String, response: ORSSerialPacketDescriptor? = nil, cmdTimeout: Double = defaultTimeoutSerialSeconds )
    {
        let commandStr = self.cmdPrefix + command + self.cmdSuffix
        let command = commandStr.data(using: String.Encoding.ascii)!
        
        self.commandsPending += 1
        print("|\(self.commandsPending) \(commandStr)|")
        let request = ORSSerialRequest(dataToSend: command,
                                       userInfo: self.commandsPending,
                                       timeoutInterval: cmdTimeout,
                                       responseDescriptor: response)
        self.serialPort?.send(request)
    }
    
    // ORSSerialPortDelegate
    func serialPort(_ serialPort: ORSSerialPort, didReceive responseData: Data)
    {
        if let string = String(data: responseData, encoding: String.Encoding.utf8) {
            print("\(string)")
        }
        self.commandsPending -= 1
        if(self.commandsPending == 0) {exit(0)}
    }
    func serialPort(_ serialPort:ORSSerialPort, request: ORSSerialRequest) {
        print(">t \(request.responseDescriptor.debugDescription)")
    }

    func serialPortWasRemovedFromSystem(_: ORSSerialPort) {
        self.serialPort = nil
        exit(2)
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port \(serialPort) encountered error: \(error)\n")
        exit(3)
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) was opened\n")
    }
}
