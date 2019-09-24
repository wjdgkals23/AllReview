 #!/bin/bash
pod deintegrate
sudo gem install cocoapods-clean
pod clean
pod setup
pod install
