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
    
    @Option(name: .shortAndLong, default: "platform=iOS Simulator,name=iPhone 8,OS=13.3", help: "The destination")
    private var destination: String
    
    @Option(name: .shortAndLong, default: "iphonesimulator", help: "The sdk")
    private var sdk: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        
        logging(verbose: true, text: "[SIMCLI] Compile \(path) using scheme \(scheme)")
        logging(verbose: verbose, text: "using destination \(destination)")
        logging(verbose: verbose, text: "using SDK \(sdk)")
        
        let result: Result<CommandResult, CommandError> = Process().build(withVerboseMode: verbose, "-workspace", "\(path)", "-scheme", "\(scheme)", "-destination", "\(destination)", "-sdk", "\(sdk)", "-derivedDataPath", "./build", "build")
        switch result {
        case .success(_):
            logging(verbose: true, text: "\n✅ Successfully compiled")
        case .failure(_):
            throw RuntimeError("Couldn't compile the application!")
        }
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
                
                logging(verbose: verbose, text: "version replaced and file updated")
                logging(verbose: true, text: "\n✅ Successfully replaced")
            }
            catch {
                throw RuntimeError("Couldn't replace the version!")
            }
        } else {
            throw RuntimeError("Couldn't find the file in path \(path)!")
        }
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
            logging(verbose: true, text: "\n✅ Successfully downloaded")
        case .failure(_):
            throw RuntimeError("Couldn't download the library!")
        }
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
            logging(verbose: true, text: "\n✅ Successfully installed")
        case .failure(_):
            throw RuntimeError("Couldn't install the application \(name)!")
        }
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
            logging(verbose: true, text: "\n✅ Successfully uninstalled")
        case .failure(_):
            throw RuntimeError("Couldn't uninstall application \(bundleId)!")
        }
    }
}

struct Applaunch: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Launch the application")
    
    @Argument(help: "The bundle identifier of the application")
    private var bundleId: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Launch application \(bundleId)")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "launch", "booted", bundleId, "--console")
        switch result {
        case .success(_):
            logging(verbose: true, text: "\n✅ Successfully launched")
        case .failure(_):
            throw RuntimeError("Couldn't launch the application \(bundleId)!")
        }
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
            logging(verbose: true, text: "\n✅ Successfully terminated")
        case .failure(_):
            throw RuntimeError("Couldn't launch the application \(bundleId)!")
        }
    }
}

struct Appsetpermissions: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Set application needed permissions")
    
    @Argument(help: "The bundle identifier of the application")
    private var bundleId: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Set permissions for \(bundleId)")
        
        let result: Result<CommandResult, CommandError> = Process().utils(withVerboseMode: verbose, "--booted", "--bundle", bundleId, "--setPermissions", "microphone=YES")
        switch result {
        case .success(_):
            logging(verbose: true, text: "\n✅ Successfully set")
        case .failure(_):
            throw RuntimeError("Couldn't set permissions for application \(bundleId)!")
        }
    }
}
