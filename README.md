# simctl-cli

Experimentation in Swift around [Swift-Argument-Parser](https://github.com/apple/swift-argument-parser) to build a CLI tool for automating tasks around building and launching a tests application in the Simulator.

## Description

this tool allows to

-   Select the Rainbow SDK version to use from Carthage (ie: replace the version in `Cartfile`)
-   Install it into the application path (ie: `carthage update`)
-   Compile the application using `xcodebuild`
-   Copy binary into the `Simulator`
-   Start the app and automatically launch the tests
-   Get the result file

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
-   Optionaly display it

```bash

$ simcli start --model "iPhone 8"

```
