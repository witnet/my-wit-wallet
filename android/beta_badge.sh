#!/bin/bash

# ? -if tag-dev == true
# ? This adds a beta badge to all tags/releases with -dev in them

convert -composite ./app/src/main/res/drawable-mdpi/ic_launcher_foreground.png ./fastlane/beta/drawable-mdpi/beta_badge.png ./app/src/main/res/drawable-mdpi/ic_launcher_foreground.png
convert -composite ./app/src/main/res/drawable-hdpi/ic_launcher_foreground.png ./fastlane/beta/drawable-hdpi/beta_badge.png ./app/src/main/res/drawable-hdpi/ic_launcher_foreground.png
convert -composite ./app/src/main/res/drawable-xhdpi/ic_launcher_foreground.png ./fastlane/beta/drawable-xhdpi/beta_badge.png ./app/src/main/res/drawable-xhdpi/ic_launcher_foreground.png
convert -composite ./app/src/main/res/drawable-xxhdpi/ic_launcher_foreground.png ./fastlane/beta/drawable-xxhdpi/beta_badge.png ./app/src/main/res/drawable-xxhdpi/ic_launcher_foreground.png
convert -composite ./app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png ./fastlane/beta/drawable-xxxhdpi/beta_badge.png ./app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png

echo "Beta Badge Added"