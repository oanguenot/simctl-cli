//
//  File.swift
//
//
//  Created by Olivier Anguenot on 15/03/2020.
//

import Foundation
import ArgumentParser

struct Appcompile: ParsableCommand {
    
    public static let configuration = CommandConfiguration(abstract: "Compile AfterbuildIOS")
    
    @Argument(help: "The path of the workspace")
    private var path: String
    
    @Option(name: .shortAndLong, default: "", help: "The scheme")
    private var scheme: String
    
    @Option(name: .shortAndLong, default: "platform=iOS Simulator,name=iPhone 8,OS=13.4", help: "The destination")
    private var destination: String
    
    @Option(name: .shortAndLong, default: "iphonesimulator", help: "The sdk")
    private var sdk: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        
        logging(verbose: true, text: "[SIMCLI] Compile \(path) using scheme \(scheme)")
        logging(verbose: verbose, text: "using destination \(destination)")
        logging(verbose: verbose, text: "using SDK \(sdk)")
        
        let result: Result<CommandResult, CommandError> = Process().build(withVerboseMode: verbose, withCapture: false, "-workspace", "\(path)", "-scheme", "\(scheme)", "-destination", "\(destination)", "-sdk", "\(sdk)", "-derivedDataPath", "./build", "clean", "build")
        switch result {
        case .success(_):
            logging(verbose: true, text: "Successfully compiled")
        case .failure(_):
            throw RuntimeError("Couldn't compile the application!")
        }
        
        throw ExitCode.success
    }
}

struct Appreplace: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Replace Rainbow SDK version in Cartfile")
    
    @Argument(help: "The path of the Cartfile")
    private var path: String
    
    @Option(name: .shortAndLong, default: "1.67", help: "The version to add")
    private var version: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Replace Carthage file \(path) with new Rainbow SDK version \(version)")
        
        let fileManager: FileManager = FileManager.default
        
        let stringToCopy = """
        # Rainbow SDK binary framework
        binary "https://sdk.openrainbow.io/ios/carthage/RainbowSDK.json" == \(version)\n
        """
        
        if (fileManager.fileExists(atPath: path)) {
            do {
                logging(verbose: verbose, text: "file \(path) has been found")
                
                try stringToCopy.write(toFile: path, atomically: true, encoding: .utf8)
                
                logging(verbose: true, text: "Successfully updated")
            }
            catch {
                throw RuntimeError("Couldn't replace the version!")
            }
        } else {
            throw RuntimeError("Couldn't find the file in path \(path)!")
        }
        
        throw ExitCode.success
    }
}

struct Appdownload: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Download Rainbow SDK")
    
    @Argument(help: "The path of the Cartfile")
    private var path: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Download Rainbow SDK from Carthage in path \(path)")
        
        let result: Result<CommandResult, CommandError> = Process().carthage(withVerboseMode: verbose, "update", "--project-directory", path)
        switch result {
        case .success(_):
            logging(verbose: true, text: "Successfully downloaded")
        case .failure(_):
            throw RuntimeError("Couldn't download the library!")
        }
        
        throw ExitCode.success
    }
}

struct Appinstall: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Install an application")
    
    @Argument(help: "The name of the application")
    private var name: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Install application \(name)")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "install", "booted", "./build/Build/Products/Debug-iphonesimulator/\(name).app")
        switch result {
        case .success(_):
            logging(verbose: true, text: "Successfully installed")
        case .failure(_):
            throw RuntimeError("Couldn't install the application \(name)!")
        }
        
        throw ExitCode.success
    }
}

struct Appuninstall: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Uninstall an application")
    
    @Argument(help: "The bundle identifier of the application")
    private var bundleId: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Uninstall application \(bundleId)")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "uninstall", "booted", bundleId)
        switch result {
        case .success(_):
            logging(verbose: true, text: "Successfully uninstalled")
        case .failure(_):
            throw RuntimeError("Couldn't uninstall application \(bundleId)!")
        }
        
        throw ExitCode.success
    }
}

struct Applaunch: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Launch the application")
    
    @Argument(help: "The bundle identifier of the application")
    private var bundleId: String
    
    @Option(name: .shortAndLong, default: "", help: "The tests to launch using a comma delimited string (ex: test_A,test_B)")
    private var args: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Launch application \(bundleId)")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "launch", "booted", bundleId, "-args", args)
        switch result {
        case .success(_):
            logging(verbose: true, text: "Successfully launched")
        case .failure(_):
            throw RuntimeError("Couldn't launch the application \(bundleId)!")
        }
        
        throw ExitCode.success
    }
}

struct Appterminate: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Terminate an application")
    
    @Argument(help: "The bundle identifier of the application")
    private var bundleId: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Terminate application \(bundleId)")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "terminate", "booted", bundleId)
        switch result {
        case .success(_):
            logging(verbose: true, text: "Successfully terminated")
        case .failure(_):
            throw RuntimeError("Couldn't launch the application \(bundleId)!")
        }
        
        throw ExitCode.success
    }
}

struct Appgrantpermissions: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Grant all permissions to application")
    
    @Argument(help: "The bundle identifier of the application")
    private var bundleId: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Grant all permissions for \(bundleId)")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "privacy", "booted", "grant", "all", bundleId)
        switch result {
        case .success(_):
            logging(verbose: true, text: "Successfully granted")
        case .failure(_):
            throw RuntimeError("Couldn't grant permissions for application \(bundleId)!")
        }
        
        throw ExitCode.success
    }
}

struct Appgetdatapath: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Get the path of the application data")
    
    @Argument(help: "The bundle identifier of the application")
    private var bundleId: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: verbose, text: "[SIMCLI] Get application data path for \(bundleId)")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "get_app_container", "booted", bundleId, "data")
        switch result {
        case .success(let result):
            logging(verbose: verbose, text: "Successfully got")
            if let path = result.data {
                let str =  String(data: path, encoding: .utf8) ?? ""
                print(str)
            }
            
        case .failure(_):
            throw RuntimeError("Couldn't set permissions for application \(bundleId)!")
        }
        
        throw ExitCode.success
    }
}
