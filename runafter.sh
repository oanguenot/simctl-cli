#!/bin/bash
echo "----- [Starting Afterbuid script] -----"

# Variables
sdk="1.68.0"
model="iPhone 8"
projectName="AfterbuildTest"
projectPath="/Users/oan/github/afterbuildios"
projectNamespace="com.olivier"
tests="Login,Contacts,Conversations,IM,Groups,Favorites,Bubbles,Channels"

# Update Carthage file
echo "----- [Update Rainbow SDK version in Cartfile] -----"
swift run simcli appreplace "$projectPath/$projectName/Cartfile" --version $sdk

# Update Dependencies
echo "----- [Download Rainbow SDK] -----"
swift run simcli appdownload "$projectPath/$projectName"

# Compile application
echo "----- [Compile Afterbuild] -----"
swift run simcli appcompile "$projectPath/$projectName.xcworkspace" --scheme $projectName

if [ $? -ne 0 ]
then
	exit 1
fi

# Start simulator
echo "----- [Start simulator] -----"
swift run simcli simustart --model "$model" --visible

# Install the application
echo "----- [Install Afterbuild] -----"
swift run simcli appinstall "$projectName"

# Set the permissions
echo "----- [Set permissions] -----"
swift run simcli appsetpermissions "$projectNamespace.$projectName"

# Start the application
echo "----- [Start application] -----"
swift run simcli applaunch "$projectNamespace.$projectName" --args "$tests" 

# Get the XML result
echo "----- [Get XML Result file] -----"

# Stop the application
echo "----- [Stop application] -----"

# Uninstall application
echo "----- [Uninstall application] -----"

# Stop the simulator
echo "----- [Stop simulator] -----"


#echo "----- [Finished Afterbuild script] -----"



