import ArgumentParser
import Foundation


struct simctlcli: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line for managing the simulator",
        subcommands: [Compile.self, Replace.self]
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
        if verbose {
            print("Compile...")
        }
        
        let result = Process().build("-workspace", "\(path)", "-scheme", "\(scheme)", "-destination", "\(destination)", "-sdk", "\(sdk)", "build")
        print("Result: \(String(result))")
    }
}

struct Replace: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "Replace version in CartFile")
    
    @Argument(help: "The path of the Cartfile")
    private var path: String
    
    @Option(name: .shortAndLong, default: "1.67", help: "The version to add")
    private var version: String
    
    func run() throws {
        
        let fileManager: FileManager = FileManager.default
       
        let stringToCopy = """
        # Rainbow SDK binary framework
        binary "https://sdk.openrainbow.io/ios/carthage/RainbowSDK.json" == \(version)\n
        """
        
        if (fileManager.fileExists(atPath: path)) {
            do {
                print("Replace with version: \(version)...")
                try stringToCopy.write(toFile: path, atomically: true, encoding: .unicode)
                print("Replaced!")
            }
            catch {
                print("Error: \(error)")
            }
        } else {
            print("File not found: \(path)")
        }
    }
}

simctlcli.main()

