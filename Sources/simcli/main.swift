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
            Appcompile.self,
            Appreplace.self,
            Appdownload.self,
            Simustart.self,
            Simustop.self,
            Appinstall.self,
            Appuninstall.self,
            Applaunch.self,
            Appterminate.self,
            Appgrantpermissions.self,
            Appgetdatapath.self
        ]
    )
    
    init() { }
}

simctlcli.main()
