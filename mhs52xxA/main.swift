//
//  main.swift
//  mhs52xxA
//
//  Created by Kevin Peck on 2018-11-14.
//  Copyright © 2018 House of Kevin Peck. All rights reserved.
//

import Foundation
import ORSSerial

let defaultBaudRate = 57600
let defaultDivisions = 16
let defaultTimeoutSerialSeconds:Double = 4
let defaultMaxResponseLength:UInt = 20

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}

func printUsage() {
    let msg: Array<String> = ["Usage of '\(CommandLine.arguments[0])' <serial device path> [-B <baud rate: default \(defaultBaudRate)>] [-d <divisions: default \(defaultDivisions)>]... "
        , "-c <command string to device where response is 'ok'>"
        , "-C <command string to device where response is command string plus return info>"
        , "-l <command prefix where '#' is replaced by division number> <file path to data file>"
        , ""
        , "'divisions' are number of segments to make from -l command's data elements."
        , "Data file can be list of numbers in CSV or TXT format where each number is "
        , "separated by [space][tab][,] or [newline]."
        , ""
        , "There can be N number of optional commands sent to device, in order specified."
        , "The intent is to form commands for device setup or loading of arbitrary waveforms."
        , ""
        , "Example: \(CommandLine.arguments[0]) /dev/cu.whcf010 -c s1b0 -c s1w1 -l a#E ~/data.csv -c s1w15 -c s1f15000 -c s11"
        , "This example turns of Channel 1, switches waveform to sine wave, loads arbitrary waveform 15 from data.csv, switches waveform to arb. 15, sets frequency 1.5kHz, and turns on channel 1."
    ]
    
    print(msg.joined(separator:"\n"))
}

setbuf(stdout, nil)

if CommandLine.argc < 2 {
    printUsage();
    exit(1);
}

let serialDevice = CommandLine.arguments[1]
var baudRate = defaultBaudRate
var timeoutSerialSeconds = defaultTimeoutSerialSeconds
var divisions = defaultDivisions
var serialCtrl: SerialPortController?  = nil
var maxResponseLength = defaultMaxResponseLength

var i = 2
let index = Int(i)
if( CommandLine.arguments[index] == "-B" ) {
    let index2 = Int(i+1)
    if(Int(CommandLine.arguments[index2]) != nil) {
        baudRate = Int(CommandLine.arguments[index2])!
    }
    i += 2
}

serialCtrl = SerialPortController.init(portPath: serialDevice
    , portBaudRate: NSNumber(integerLiteral: baudRate))

while( i < CommandLine.argc && serialCtrl != nil) {
    let index = Int(i)
    switch( CommandLine.arguments[index] ) {
    case "-d":
        let index2 = Int(i+1)
        if(Int(CommandLine.arguments[index2]) != nil) {
            divisions = Int(CommandLine.arguments[index2])!
        }
        i += 2
    case "-c":
        let index2 = Int(i+1)
        print("queued: \(CommandLine.arguments[index2]) ...")
        serialCtrl?.sendCommand(command:CommandLine.arguments[index2]
            ,response: ORSSerialPacketDescriptor(prefixString: "ok", suffixString: "\n", maximumPacketLength: UInt("ok\n".count), userInfo: nil));
        i += 2
    case "-C":
        let index2 = Int(i+1)
        let commandEcho = ":" + CommandLine.arguments[index2]
        print("queued: \(CommandLine.arguments[index2]) ...")
        serialCtrl?.sendCommand(command:CommandLine.arguments[index2]
            , response: ORSSerialPacketDescriptor(prefixString: commandEcho, suffixString: "\n", maximumPacketLength: maxResponseLength, userInfo: nil));
        i += 2
    case "-l":
        let index2 = Int(i+1)
        let command = CommandLine.arguments[index2]
        let index3 = Int(i+2)
        let fileNamePath = CommandLine.arguments[index3]
        do {
            // Get the contents
            let contents = try NSString(contentsOfFile: fileNamePath, encoding: String.Encoding.ascii.rawValue)
            let numbersList = contents.components(separatedBy: CharacterSet(charactersIn: ",\t\n "))
            let justNumbers = numbersList.filter({$0 != "" && $0.isInt});
            let lineCount = UInt(justNumbers.count / divisions)
            var divisionIndex = 0
            var cmdNumbers = ""
            for j in 1...justNumbers.count {
                if( (Int(j) % Int(lineCount)) == 0) {
                    let cmd = command.replacingOccurrences(of: "#", with: String(format:"%01X", divisionIndex))
                    print("queued: \(cmd) ...")
                    let line = cmd + cmdNumbers.dropLast()
                    serialCtrl?.sendCommand(command: line
                        ,response: ORSSerialPacketDescriptor(prefixString: "ok", suffixString: "\n", maximumPacketLength: UInt("ok\n".count), userInfo: nil));
                    divisionIndex += 1
                    cmdNumbers = justNumbers[j-1] + ","
                } else {
                    cmdNumbers += justNumbers[j-1] + ","
                }
            }
        }
        catch let error as NSError {
            print("Ooops! Something went wrong reading '\(fileNamePath)': \(error)")
            exit(5)
        }
        i += 3
    default:
        print("\(CommandLine.arguments[index])\n")
    }
}

RunLoop.current.run() // loop


/*
func handleUserInput(dataFromUser: Data) {
    if let string = String(data: dataFromUser, encoding: String.Encoding.utf8) {
        
        if string.lowercased().hasPrefix("exit") ||
            string.lowercased().hasPrefix("quit") {
            print("Quitting...\n")
            exit(EXIT_SUCCESS)
        }
        self.serialPort?.send(dataFromUser)
    }
}


standardInputFileHandle.readabilityHandler = { (fileHandle: FileHandle!) in
    let data = fileHandle.availableData
    DispatchQueue.main.async { () -> Void in
        self.handleUserInput(dataFromUser: data)
    }
}

*/
