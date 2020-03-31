# SimCLI [![Build Status](https://travis-ci.org/oanguenot/simctl-cli.svg?branch=master)](https://travis-ci.org/oanguenot/simctl-cli)

`SimCLI` is an experimental command line tool written in Swift using [Swift-Argument-Parser](https://github.com/apple/swift-argument-parser) for automating tasks needed to test an application in the Simulator.

## Description

When building a library or SDK that connects to a platform such as [Rainbow](https://www.openrainbow.com), it's sometime complicated to maintain a compatibility and so to detect that an existing delivered version is no more working due to a platform enhancement.

The goal of this tool is to automate as much as possible all the tasks in order to be able to configure and test all the existing versions of the library/SDK in an autonomous way.

Additionnaly, we use an ALE home-made SDK-testing tool called `Afterbuild IOS` which is an application that connects to our **Rainbow** platform and calls public API of the SDK based on JSON scenarios. **Afterbuild IOS** will then check the public events and/or data received in order to make assertions. Results of these assertions are saved into a **JUnit XML file**.

`SimCLI` proposes the following commands:

-   Select the Rainbow SDK version to use from Carthage (ie: replace the version in `Cartfile`)
-   Install it into the **Afterbuild IOS** application path (ie: `carthage update`)
-   Compile the **Afterbuild IOS** application using `xcodebuild`
-   Start a `Simulator`
-   Install / uninstall the **Afterbuild IOS** application to Simulator
-   Authorize the **Afterbuild IOS** application to access the microphone (needed by the SDK)
-   Start the **Afterbuild IOS** application and automatically launch the tests campaign
-   Get the path where the **Afterbuild IOS** application stores data (when launched from the simulator) in order to retrieve the JUnit XML file

This tool is deeply linked to [Rainbow](https://www.openrainbow.com) and **Afterbuild IOS** in a first step but the goal is to have at the end an agnostic CLI tool that help testers to automate their own testing flows.

## Prerequisites

`XCode 11.4` (Minimum) and the associated `Command Line Tool` are required.

## Installation

After cloning the repository, launch the following commands to install `SimCLI` in your computer

```bash

$ swift build --configuration release
$ cp -f .build/release/simcli /usr/local/bin/simcli

```

Just use `SimCLI` now to execute your commands

## Commands

### Update Carthage file

This command replaces the version of the [Rainbow SDK](https://hub.openrainbow.com) library used in the `Carthage` file.

```bash

$ simcli appreplace "/Users/oan/github/afterbuildios/AfterbuildTest/Cartfile" --version "1.70.5"

```

Note: At this time of writing, `SimCLI` rewrites the Carthage file by just adding an hardcoded reference to the `Rainbow SDK` version specified.

### Update Carthage dependencies

This command updates the application by downloading and installing the right version of the Rainbow SDK from Carthage. This command is equivalent to `carthage update`.

```bash

$ simcli appdownload "/Users/oan/github/afterbuildios/AfterbuildTest"

```

The path corresponds to the `Cartfile` folder.

### Compile application

This command compiles the application by selecting the project and the scheme.

```bash

$ simcli appcompile "/Users/oan/github/afterbuildios/AfterbuildTest.xcworkspace" --scheme "AfterbuildTest"

```

Option `--destination` could be used to specify how it should be compiled. By default equals to  `platform=iOS Simulator,name=iPhone 8,OS=13.4`.

Option `--sdk` can be used. By default equals to `iphonesimulator`.

### Starting simulator

This command does several things:

-   Find if the simulator model selected is available (by default use `iPhone 8`)
-   Stop the simulator if runs
-   Erase the content if exists
-   Boot the simulator
-   Optionaly display it (by default not)

```bash

$ simcli simustart --model "iPhone 8"

```

### Stopping all running Simulators

In case you need to stop all simulators, use that command:

```bash

$ simcli simustop

```

### Install an application

This command copies the binary to the simulator

```bash

$ simcli appinstall "AfterbuildTest"

```

_Note_: This command requires the name of the application.

### Uninstall an application

In case, you need to uninstall the application from the Simulator, use that command

```bash

$ simcli appuninstall "com.olivier.AfterbuildTest"

```

_Note_: This command requires the bundleId of the application.

### Grant permissions

If the application needs some permissions, you can use that command to set `all` permissions to the application.

```bash

$ simcli appgrantpermissions "com.olivier.AfterbuildTest"

```

_Note_: This command requires the bundleId of the application.

### Starting an application

An application is started by launching the command:

```bash

$ simcli applaunch "com.olivier.AfterbuildTest" --args "Login,Contacts"

```

_Note_: This command requires the bundleId of the application.

Argument `args` is used to send parameters to the application. In the case of **Afterbuild**, this is the **tests campaign** to launch automatically when application starts.

The application handles that argument using the `UserDefaults` such as in the following example

```swift

 if let tests = UserDefaults.standard.string(forKey: "args") {
     // Do something with the value received
    let listOfTests = tests.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
    run(listOfTests)
 }

```

### Getting the application's data path

This command returns the path where the application writes files.

```bash

$ simcli appgetdatapath "com.olivier.AfterbuildTest"

```

_Note_: This command requires the bundleId of the application.

This command returns a string containing the path to the application's directory.

### Stopping an application

An application is stopped by launching the command:

```bash

$ simcli appterminate "com.olivier.AfterbuildTest"

```

_Note_: This command requires the bundleId of the application.

### Complete sample

File `runafter.sh` is a `bash` script file that demonstrates the use of `simcli`.

This sample downloads a `Rainbow SDK` version and compiles our home-made tests application `Afterbuild IOS` with it. Once done, the script launches a simulator, executes the application and gets the `Jenkins JUnit XML` file generated. This automated process can be launched by `Jenkins`.

Don't hesitate to adapt for your needs.

To launch it, execute the following command:

```bash

$ sh runafter.sh "1.70.0"

```

The parameter `1.70.0` is the **Rainbow SDK** version to install.
