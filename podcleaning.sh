#!/bin/bash
pod clean
rm -rf Pods *.xcworkspace Podfile.lock
pod install
