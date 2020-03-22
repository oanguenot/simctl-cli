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
    var data: Data?
}

extension Process {
    
    @discardableResult
    func exe(command: String, withCapture: Bool = true, withVerboseMode: Bool, _ args: [String]) -> Result<CommandResult, CommandError> {
        
        logging(verbose: withVerboseMode, text:"Executing command \(command)...")
        
        self.launchPath = command
        self.arguments = args
        
        let pipe = Pipe()
        
        if(withCapture) {
            self.standardOutput = pipe
            self.standardError = pipe
        }
        
        if #available(OSX 10.14, *) {
            do {
                try self.run()
            } catch {
                logging(verbose: true, text:"Couldn't terminate the command - \(error.localizedDescription)")
                return .failure(CommandError(code: -1, type: .NOT_TERMINATED))
            }
        } else {
            self.launch()
        }
        
        self.waitUntilExit()
        
        var data: Data?
        var output: String = ""
        if(withCapture) {
            data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let data = data {
                output = String(data: data, encoding: .utf8) ?? ""
            }
        }
        
        logging(verbose: withVerboseMode, text:"Command terminated with status [\(String(self.terminationStatus))]")
        
        if self.terminationStatus != 0 {
            if(withCapture) {
                logging(verbose: true, text:output)
            }
            return .failure(CommandError(code: Int(self.terminationStatus), type: .NOT_TERMINATED))
        } else {
            logging(verbose: withVerboseMode, text:output)
            return .success(CommandResult(code: Int(self.terminationStatus), data: data))
        }
    }

    @discardableResult
    func xcrun(withVerboseMode: Bool = false, withCapture: Bool = true, _ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/bin/xcrun", withCapture: withCapture, withVerboseMode: withVerboseMode, args)
    }
    
    @discardableResult
    func build(withVerboseMode: Bool = false, withCapture: Bool = true ,_ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/bin/xcodebuild", withCapture: withCapture , withVerboseMode: withVerboseMode, args)
    }
    
    @discardableResult
    func carthage(withVerboseMode: Bool = false, withCapture: Bool = true ,_ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/local/bin/carthage", withCapture: withCapture , withVerboseMode: withVerboseMode, args)
    }
    
    @discardableResult
    func open(withVerboseMode: Bool = false, withCapture: Bool = true ,_ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/bin/open", withCapture: withCapture , withVerboseMode: withVerboseMode, args)
    }
    
    @discardableResult
    func utils(withVerboseMode: Bool = false, withCapture: Bool = true ,_ args: String...) -> Result<CommandResult, CommandError> {
        return self.exe(command: "/usr/local/bin/applesimutils", withCapture: withCapture , withVerboseMode: withVerboseMode, args)
    }
}

