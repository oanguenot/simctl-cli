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
        abstract: "An experimental Swift command-line tool for managing the Simulator",
        subcommands: [
            Compile.self,
            Replace.self,
            Download.self,
            Start.self,
            Install.self,
            Uninstall.self,
            Launch.self,
            Setpermissions.self]
    )
    
    init() { }
}

simctlcli.main()
