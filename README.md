# simcli

Experimental command line tool written in Swift using [Swift-Argument-Parser](https://github.com/apple/swift-argument-parser) for automating tasks needed to test an application in the Simulator.

## Description

When building a library or SDK that connects to a platform such as [Rainbow](https://www.openrainbow.com), it's sometime complicated to maintain a compatibility and so to detect that an existing delivered version is no more working due to a platform enhancement.

The goal of this tool is to automate as much as possible all the tasks in order to be able to configure and test all the existing versions of the library/SDK in an autonomous way.

This tool allows to

-   Select the Rainbow SDK version to use from Carthage (ie: replace the version in `Cartfile`)
-   Install it into the application path (ie: `carthage update`)
-   Compile the application using `xcodebuild`
-   Start a `Simulator`
-   Install / uninstall application on Simulator
-   Authorize the application to access the microphone (needed by the SDK)
-   Start the app and automatically launch the tests
-   Get the result file

This tool is deeply linked to Rainbow in a first step but the goal is to have at the end an agnostic CLI tool that help testers to automate their testing flows.

## Prerequisites

[Apple Simulator Utils](https://github.com/wix/AppleSimulatorUtils) should be installed to set the application permissions.

This is subject to change as rumors say that in Xcode 11.4, application's permissions will be managed directly in the Simulator for easing tests.

## Commands

### Update Carthage file

This command replace the version of the [Rainbow SDK](https://hub.openrainbow.com) library used in the `Carthage` file.

```bash

$ simcli appreplace "/Users/oan/github/afterbuildios/AfterbuildTest/Cartfile" --version "1.70.5"

```

### Update Carthage dependencies

This command updates the application by download and installing the right version of the Rainbow SDK from Carthage. This command is equivalent to `carthage update`.

```bash

$ simcli appdownload "/Users/oan/github/afterbuildios/AfterbuildTest"

```

The path corresponds to the `Cartfile` folder.

### Compile application

This application compiles the application by selecting the project and the scheme.

```bash

$ simcli appcompile "/Users/oan/github/afterbuildios/AfterbuildTest.xcworkspace" --scheme "AfterbuildTest"

```

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

This command copy the binary to the simulator

```bash

$ simcli appinstall "AfterbuildTest"

```

_Note_: This commands requires the name of the application.

### Uninstall an application

In case, you need to uninstall the application from the Simulator, use that command

```bash

$ simcli appuninstall "com.olivier.AfterbuildTest"

```

_Note_: This commands requires the bundleId of the application.

### Setting permissions

The application needs to access the microphone (ie: a popup to authorize the application is displayed when the application starts) to work properly.

This command (based on **Apple Simulator Utils**) authorize the application automatically (ie: without user interaction).

```bash

$ simcli appsetpermissions "com.olivier.AfterbuildTest"

```

_Note_: This commands requires the bundleId of the application.

### Starting an application

An application can be started by launching the command:

```bash

$ simcli applaunch "com.olivier.AfterbuildTest" --args "Login,Contacts"

```

_Note_: This commands requires the bundleId of the application.

Argument `args` is used to send parameters to the application. In the case of **Afterbuild**, this is the **tests campaign** to launch automatically on application start.

Application can handle that argument using the `userDefaults` such as the following example

```swift

 if let tests = UserDefaults.standard.string(forKey: "args") {
     // Do something with the value received
    let listOfTests = tests.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
    run(listOfTests)
 }

```

### Stopping an application

An application can be stopped by launching the command:

```bash

$ simcli appterminate "com.olivier.AfterbuildTest"

```

_Note_: This commands requires the bundleId of the application.

### To complete...
