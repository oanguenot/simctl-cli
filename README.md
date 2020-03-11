# simctl-cli

CLI tool for automating tests around Rainbow SDK.

## Description

this tool allows to

-   Select the Rainbow SDK version to use from Carthage (ie: replace the version in `Cartfile`)
-   Install it into the application path (ie: `carthage update`)
-   Compile the application using `xcodebuild`
-   Copy binary into the `Simulator`
-   Start the app and automatically launch the tests
-   Get the result file

### In progress
