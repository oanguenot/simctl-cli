import ArgumentParser
import Foundation

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}

struct simctlcli: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line for managing the simulator",
        subcommands: [Compile.self, Replace.self, Download.self, Start.self]
    )
    
    init() { }
}

struct Compile: ParsableCommand {
    
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
        
        let result: Result<CommandResult, CommandError> = Process().build(withVerboseMode: verbose, "-workspace", "\(path)", "-scheme", "\(scheme)", "-destination", "\(destination)", "-sdk", "\(sdk)", "build")
        switch result {
        case .success(_):
            logging(verbose: true, text: "\n✅ Successfully compiled")
        case .failure(let error):
            logging(verbose: true, text: "\n❌ Compilation failed with code \(String(error.code))")
        }
    }
}

struct Replace: ParsableCommand {
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
                logging(verbose: true, text: "\n❌ Replace failed - error \(error.localizedDescription)")
            }
        } else {
            logging(verbose: true, text: "\n❌ Replace failed - file not found \(path)")
        }
    }
}

struct Download: ParsableCommand {
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
        case .failure(let error):
            logging(verbose: true, text: "\n❌ Download failed with code \(String(error.code))")
        }
    }
}

struct Start: ParsableCommand {
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
        case .failure(let error):
            throw RuntimeError("Couldn't get simulator start due to error '\(String(error.code))'!")
        }
        
        // display it
        if(visible) {
            logging(verbose: verbose, text: "\(model) simulator will be displayed")
            let displayResult = Process().open(withVerboseMode: verbose, "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/" )
            switch displayResult {
            case .success(_):
                logging(verbose: verbose, text: "\(model) simulator has been displayed")
            case .failure(let error):
                throw RuntimeError("Couldn't get simulator display due to error '\(String(error.code))'!")
            }
        }
        
        logging(verbose: true, text: "\n✅ Successfully started \(name) [\(udid)]")
    }
}

simctlcli.main()
