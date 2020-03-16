//
//  File.swift
//  
//
//  Created by Olivier Anguenot on 15/03/2020.
//

import Foundation
import ArgumentParser

struct Simustart: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Start the simulator")
    
    func getDeviceIfExist(listOfDevices: Array<Dictionary<String, AnyHashable>>, model: String) -> Dictionary<String, AnyHashable>? {
        
        var deviceFound: Dictionary<String, AnyHashable>?
        
        listOfDevices.forEach {
            let available = $0["isAvailable"] as! Bool
            let name = $0["name"] as! String
            
            if (available && name == model) {
                deviceFound = $0
            }
        }
        return deviceFound
    }
    
    @Option(name: .shortAndLong, default: "iPhone 8", help: "The iphone model to start")
    private var model: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    @Flag(name: .shortAndLong, help: "Display the simulator. Not displayed by default")
    private var visible: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Start a new simulator using model \(model)")
        
        var deviceFound: Dictionary<String, AnyHashable>?
        
        // Get all devices
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "list", "-j")
        
        switch result {
        case .failure(let error):
            throw RuntimeError("Couldn't get simulator list '\(String(error.code))'!")
        case .success(let object):
            let json = (try! JSONSerialization.jsonObject(with: object.data, options: [])) as! Dictionary<String, Any>
            let runtimes = json["devices"] as! Dictionary<String, Array<Any>>
            let allDevices = runtimes.values.flatMap { $0 } as! Array<Dictionary<String, AnyHashable>>
            deviceFound = getDeviceIfExist(listOfDevices: allDevices, model: model)
        }
        
        guard let device = deviceFound else {
            throw RuntimeError("Couldn't get this device \(model)!")
        }
        
        let name = device["name"] as! String
        let udid = device["udid"] as! String
        let state = device["state"] as! String
        
        logging(verbose: verbose, text: "\(name) simulator is available [\(udid)]")
        logging(verbose: verbose, text: "\(name) simulator is in state \(state)")
        
        if state != "Shutdown" {
            // shutdown it
            logging(verbose: verbose, text: "\(model) simulator will be shut-down")

            let startResult = Process().xcrun(withVerboseMode: verbose, "simctl", "shutdown", udid )
            switch startResult {
            case .success(_):
                logging(verbose: verbose, text: "\(model) simulator has been shut down")
            case .failure(let error):
                logging(verbose: true, text: "Warning, couldn't shutdown \(model) due to error \(String(error.code))")
            }
            
            //erase it
            logging(verbose: verbose, text: "\(model) simulator will erased")
            let eraseResult = Process().xcrun(withVerboseMode: verbose, "simctl", "erase", udid )
            switch eraseResult {
            case .success(_):
                logging(verbose: verbose, text: "\(model) simulator has been erased")
            case .failure(let error):
                logging(verbose: true, text: "Warning, couldn't be erased \(model) due to error \(String(error.code))")
            }
        }
        
        // start it
        logging(verbose: verbose, text: "\(model) simulator will be started")
        let bootResult = Process().xcrun(withVerboseMode: verbose, "simctl", "boot", udid )
        switch bootResult {
        case .success(_):
            logging(verbose: verbose, text: "\(model) simulator has been started")
        case .failure(_):
            throw RuntimeError("Couldn't get simulator start!")
        }
        
        // display it
        if(visible) {
            logging(verbose: verbose, text: "\(model) simulator will be displayed")
            let displayResult = Process().open(withVerboseMode: verbose, "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/" )
            switch displayResult {
            case .success(_):
                logging(verbose: verbose, text: "\(model) simulator has been displayed")
            case .failure(_):
                throw RuntimeError("Couldn't get simulator display!")
            }
        }
        
        logging(verbose: true, text: "\n✅ Successfully started \(name) [\(udid)]")
    }
}

struct Simustop: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Stop all simulators launched")
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        logging(verbose: true, text: "[SIMCLI] Stop all running Simulator")
        
        let result: Result<CommandResult, CommandError> = Process().xcrun(withVerboseMode: verbose, "simctl", "shutdown", "all")
        switch result {
        case .success(_):
            logging(verbose: true, text: "\n✅ Successfully stopped")
        case .failure(_):
            throw RuntimeError("Couldn't execute the command!")
        }
    }
}
