#!/bin/bash

export VCODE=$(bundle exec fastlane vcode | grep -o 'VersionCode: [0-9]*$' | grep -o '[0-9]*$')

echo $VCODE