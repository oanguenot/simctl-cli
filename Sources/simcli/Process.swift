//
//  File.swift
//  
//
//  Created by Olivier Anguenot on 07/03/2020.
//

import Foundation

extension Process {
    
    @discardableResult
    func exe(command: String, _ args: [String]) -> Int {
        self.launchPath = command
        self.arguments = args
        
        let pipe = Pipe()
        self.standardOutput = pipe
        self.standardError = pipe
        
        self.launch()
        self.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        print("output: \(String(describing: output))")
        
        print("status: \(String(self.terminationStatus))")
        
        print("reason: \(String(self.terminationReason.rawValue))")
        
        return Int(self.terminationStatus)
    }
    
    @discardableResult
    func xcrun(_ args: String...) -> Data {
        return self.exe(command: "/usr/bin/xcrun", args)
    }
    
    @discardableResult
    func build(_ args: String...) -> Int {
        return self.exe(command: "/usr/bin/xcodebuild", args)
    }
    
    /// Executes `xcrun simctl list devices`
    @discardableResult
    func xcrun_list_devices() -> Data {
        return self.xcrun("simctl", "list", "devices", "-j")
    }

    func xcrun_erase(_ device: String) {
        self.xcrun("simctl", "erase", device)
    }
}

