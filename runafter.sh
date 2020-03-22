#!/bin/bash
echo "----- [Starting Afterbuid script] -----"

# Variables
sdk="1.68.0"
model="iPhone 8"
projectName="AfterbuildTest"
projectPath="/Users/oan/github/afterbuildios"
projectNamespace="com.olivier"
tests="Login,Contacts,Conversations,IM,Groups,Favorites,Bubbles,Channels"

# Watcher (check every 30s, timeout=30 minutes)
maxAttempts=60
nbAttempts=0
sleepDuration=30
hasExitOnError=0

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
    echo "----- [Stopped compilation failed] -----"
	exit 1
fi

# Start simulator
echo "----- [Start simulator] -----"
swift run simcli simustart --model "$model" --visible

# Install the application
echo "----- [Install Afterbuild] -----"
swift run simcli appinstall "$projectName"

# Get the path to the application's data
path="$(swift run simcli appgetdatapath "com.olivier.AfterbuildTest")/Documents/afterbuild_jenkins.xml"

# Delete file if exists
rm -rf $path

# Set the permissions
echo "----- [Set permissions] -----"
swift run simcli appsetpermissions "$projectNamespace.$projectName"

# Start the application
echo "----- [Start application] -----"
swift run simcli applaunch "$projectNamespace.$projectName" --args "$tests"

# Wait for the JUnit XML file to be created or a timeout
while ! test -f "$path"; do
  sleep $sleepDuration
  ((nbAttempts++))
  if [[ "$nbAttempts" == "$maxAttempts" ]]; then
    echo "timeout reached..."
    hasExitOnError=1
    break
  fi
  echo "still waiting"
done

# Get the XML result
echo "----- [Get XML Result file] -----"
cp $path "./jenkins_$sdk.xml"

# Stop the application
echo "----- [Stop application] -----"
swift run simcli appterminate "com.olivier.AfterbuildTest"

# Uninstall application
echo "----- [Uninstall application] -----"
 swift run simcli appuninstall "com.olivier.AfterbuildTest"

# Stop the simulator
echo "----- [Stop simulator] -----"
 swift run simcli simustop

if [ "$hasExitOnError" -ne 0 ]
then
    echo "----- [Finished test timeouted] -----"
    exit 1
fi

echo "----- [Finished Afterbuild script] -----"
