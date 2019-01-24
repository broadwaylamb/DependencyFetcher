#!/usr/bin/env bash

echo "Swift CodeCov Integration";

# Determine OS
UNAME=`uname`;
if [[ $UNAME == "Darwin" ]];
then
    OS="macOS";
else
    echo "🚫  Unsupported OS: $UNAME, skipping...";
    exit 0;
fi
echo "🖥  Operating System: $OS";

PROJ_NAME="DependencyFetcher"
SCHEME_NAME="${PROJ_NAME}-Package"

echo "🚀  Testing: $SCHEME_NAME";

rvm install 2.2.3
gem install xcpretty
swift package generate-xcodeproj --enable-code-coverage
WORKING_DIRECTORY=$(PWD) xcodebuild -project $PROJ_NAME.xcodeproj -scheme $SCHEME_NAME -destination arch=x86_64 -configuration Debug -enableCodeCoverage YES test | xcpretty
bash <(curl -s https://codecov.io/bash)

echo "✅  Done";
