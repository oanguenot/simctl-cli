import ArgumentParser
import Foundation


struct simctlcli: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line for managing the simulator",
        subcommands: [Compile.self, Replace.self, Download.self]
    )
    
    init() { }
}

//        let deviceData = Process().xcrun_list_devices()
//        let json = (try! JSONSerialization.jsonObject(with: deviceData, options: [])) as! Dictionary<String, Any>
//        let runtimes = json["devices"] as! Dictionary<String, Array<Any>>
//        let allDevices = runtimes.values.flatMap { $0 } as! Array<Dictionary<String, AnyHashable>>
//
//        var found = false
//
//        allDevices.forEach {
//            let available = $0["isAvailable"] as! Bool
//            let name = $0["name"] as! String
//            let state = $0["state"] as! String
//            let udid = $0["udid"] as! String
//
//            if (name == "iPhone 8" && available) {
//
//                found = true
//
//                if state != "Shutdown" {
//                    //Process().xcrun_fix_status_bar(udid)
//                    Process().xcrun_erase(udid)
//                    print("❌ found a running \(name)")
//                } else {
//                    print("✅ \(name) exists but is not running")
//                }
//            }
//        }

struct Compile: ParsableCommand {

    public static let configuration = CommandConfiguration(abstract: "Compile an application")

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
        print("[Compile] \(path) using scheme \(scheme)")
        
        if verbose {
            print("using destination \(destination)")
            print("using SDK \(sdk)")
        }
        
        let result: Result<CommandResult, CommandError> = Process().build(withVerboseMode: verbose, "-workspace", "\(path)", "-scheme", "\(scheme)", "-destination", "\(destination)", "-sdk", "\(sdk)", "build")
        switch result {
        case .success(_):
            print("\n✅ Successfully compiled")
        case .failure(let error):
            print("\n❌ Compilation failed with code \(String(error.code))")
        }
    }
}

struct Replace: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Replace version in CartFile")
    
    @Argument(help: "The path of the Cartfile")
    private var path: String
    
    @Option(name: .shortAndLong, default: "1.67", help: "The version to add")
    private var version: String
    
    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    private var verbose: Bool
    
    func run() throws {
        print("[Replace] Update Carthage file \(path) to Rainbow SDK version \(version)")
        
        let fileManager: FileManager = FileManager.default
       
        let stringToCopy = """
        # Rainbow SDK binary framework
        binary "https://sdk.openrainbow.io/ios/carthage/RainbowSDK.json" == \(version)\n
        """
        
        if (fileManager.fileExists(atPath: path)) {
            do {
                if(verbose) {
                    print("file has been found")
                }
                
                try stringToCopy.write(toFile: path, atomically: true, encoding: .utf8)
                
                if(verbose) {
                    print("version replaced and file updated")
                }
                print("\n✅ Successfully replaced")
            }
            catch {
                print("\n❌ Replace failed - error \(error.localizedDescription)")
            }
        } else {
            print("\n❌ Replace failed - file not found \(path)")
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
        print("[Download] Rainbow SDK in directory \(path)")
        
        let result: Result<CommandResult, CommandError> = Process().carthage(withVerboseMode: verbose, "update", "--project-directory", path)
        switch result {
        case .success(_):
            print("\n✅ Successfully downloaded")
        case .failure(let error):
            print("\n❌ Download failed with code \(String(error.code))")
        }
    }
}

simctlcli.main()
