#!/bin/bash
echo "----- [Starting Afterbuid script] -----"

if [ $# -eq 0 ]
  then
    sdk="1.68.0"
else
    sdk=$1
fi

# Variables

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
simcli appreplace "$projectPath/$projectName/Cartfile" --version $sdk

# Update Dependencies
echo "----- [Download Rainbow SDK] -----"
simcli appdownload "$projectPath/$projectName"

# Compile application
echo "----- [Compile Afterbuild] -----"
simcli appcompile "$projectPath/$projectName.xcworkspace" --scheme $projectName

if [ $? -ne 0 ]
then
    echo "----- [Stopped compilation failed] -----"
	exit 1
fi

# Start simulator
echo "----- [Start simulator] -----"
simcli simustart --model "$model" --visible

# Install the application
echo "----- [Install Afterbuild] -----"
simcli appinstall "$projectName"

# Get the path to the application's data
path="$(swift run simcli appgetdatapath "com.olivier.AfterbuildTest")/Documents/afterbuild_jenkins.xml"

# Delete file if exists
rm -rf $path

# Set the permissions
echo "----- [Set permissions] -----"
simcli appsetpermissions "$projectNamespace.$projectName"

# Start the application
echo "----- [Start application] -----"
simcli applaunch "$projectNamespace.$projectName" --args "$tests"

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
simcli appterminate "com.olivier.AfterbuildTest"

# Uninstall application
echo "----- [Uninstall application] -----"
simcli appuninstall "com.olivier.AfterbuildTest"

# Stop the simulator
echo "----- [Stop simulator] -----"
simcli simustop

if [ "$hasExitOnError" -ne 0 ]
then
    echo "----- [Finished test timeouted] -----"
    exit 1
fi

echo "----- [Finished Afterbuild script] -----"
