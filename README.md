# simctl-cli

Experimentation in Swift around [Swift-Argument-Parser](https://github.com/apple/swift-argument-parser) to build a CLI tool for automating tasks around building and launching a tests application in the Simulator.

## Description

When building a library or SDK that connects to a platform such as [Rainbow](https://www.openrainbow.com), it's sometime complicated to maintain a compatibility and so to detect that an existing delivered version is no more working due to a platform enhancement.

The goal of this tool is to automate as much as possible all the tasks in order to be able to configure and test all the existing versions of the library/SDK in an autonomous way.

This tool allows to

-   Select the Rainbow SDK version to use from Carthage (ie: replace the version in `Cartfile`)
-   Install it into the application path (ie: `carthage update`)
-   Compile the application using `xcodebuild`
-   Start a `simulator`
-   Copy binary into it
-   Authorize the applicatio to access the microphone (needed by the SDK)
-   Start the app and automatically launch the tests
-   Get the result file

This tool is deeply linked to Rainbow in a first step but the goal is to have at the end an agnostic CLI tool that help testers to automate their testing flows.

## Prerequisites

[Apple Simulator Utils](https://github.com/wix/AppleSimulatorUtils) should be installed to set the application permissions

## Commands

### Replace

This command replace the version of the [Rainbow SDK](https://hub.openrainbow.com) library used in the `Carthage` file.

```bash

$ simcli replace "/Users/oan/github/afterbuildios/AfterbuildTest/Cartfile" --version "1.70.5"

```

### Update

This command updates the application by download and installing the right version of the Rainbow SDK from Carthage. This command is equivalent to `carthage update`.

```bash

$ simcli download "/Users/oan/github/afterbuildios/AfterbuildTest"

```

The path corresponds to the `Cartfile` folder.

### Compile

This application compiles the application by selecting the project and the scheme.

```bash

$ simcli compile "/Users/oan/github/afterbuildios/AfterbuildTest.xcworkspace" --scheme "AfterbuildTest"

```

### Start the simulator

This command does several things:

-   Find if the simulator model selected is available (by default use `iPhone 8`)
-   Stop the simulator if runs
-   Erase the content if exists
-   Boot the simulator
-   Optionaly display it (by default not)

```bash

$ simcli start --model "iPhone 8"

```

### Install binary

This command copy the binary to the simulator

```bash

$ simcli install "AfterbuildTest"

```

### Set permissions

The application needs to access the microphone (ie: a popup to authorize the application is displayed when the application starts) to work properly.

This command (based on **Apple Simulator Utils**) authorize the application automatically (ie: without user interaction).

```bash

$ simcli setpermissions "com.olivier.AfterbuildTest"

```

### Start the application

The application can be started by launching the command:

```bash

$ simcli launch "com.olivier.AfterbuildTest"

```

### To complete...
