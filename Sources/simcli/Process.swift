//
//  File.swift
//  
//
//  Created by Olivier Anguenot on 07/03/2020.
//

import Foundation

enum CommandErrorType {
    case NOT_TERMINATED
}

struct CommandError: Error {
    var code: Int
    var type: CommandErrorType
}

struct CommandResult {
    var code: Int
    var data: Any?
}

extension Process {
    
    @discardableResult
    func exe(command: String, withVerboseMode: Bool, _ args: [String]) -> Result<CommandResult, CommandError> {
        
        if(withVerboseMode) {
            print ("executing exe command \(command)...")
        }
        
        self.launchPath = command
        self.arguments = args
        
        let pipe = Pipe()
        self.standardOutput = pipe
        self.standardError = pipe
        
        self.launch()
        self.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        if(withVerboseMode) {
            print("output: \(String(describing: output))")
        }
        
        if self.terminationStatus != 0 {
            return .failure(CommandError(code: Int(self.terminationStatus), type: .NOT_TERMINATED))
        } else {
            return .success(CommandResult(code: Int(self.terminationStatus), data: output))
        }
        
    }
    
    @discardableResult
    func xcrun(withVerboseMode: Bool = false, _ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/bin/xcrun", withVerboseMode: withVerboseMode, args)
    }
    
    @discardableResult
    func build(withVerboseMode: Bool = false,_ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/bin/xcodebuild", withVerboseMode: withVerboseMode, args)
    }
    
    @discardableResult
    func carthage(withVerboseMode: Bool = false,_ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/local/bin/carthage", withVerboseMode: withVerboseMode, args)
    }
    
    
    
    /// Executes `xcrun simctl list devices`
//    @discardableResult
//    func xcrun_list_devices() -> Data {
//        //return self.xcrun("simctl", "list", "devices", "-j")
//    }
//
//    func xcrun_erase(_ device: String) {
//        //self.xcrun("simctl", "erase", device)
//    }
}

