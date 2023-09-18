# build-rust.sh

#!/bin/bash

set -e

THISDIR=$(dirname $0)
cd $THISDIR
CONFIGURATION=${1:-release}

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"
export MACOSX_DEPLOYMENT_TARGET=11.0
# Build the project for the desired platforms:
cargo build --target x86_64-apple-darwin --release
cargo build --target aarch64-apple-darwin --release
cargo build --target aarch64-apple-ios --release
cargo build --target aarch64-apple-ios-sim --release
mkdir -p ./target/universal-macos/$CONFIGURATION

lipo \
    ./target/aarch64-apple-darwin/$CONFIGURATION/libfuzzy_matcher.a \
    ./target/x86_64-apple-darwin/$CONFIGURATION/libfuzzy_matcher.a -create -output \
    ./target/universal-macos/$CONFIGURATION/libfuzzy_matcher.a

cp FuzzyMatcher/Sources/FuzzyMatcher/fuzzy-matcher.swift /tmp/fuzzy-matcher.swift
swift-bridge-cli create-package \
--bridges-dir ./generated \
--out-dir FuzzyMatcher \
--macos target/universal-macos/$CONFIGURATION/libfuzzy_matcher.a \
--simulator target/aarch64-apple-ios-sim/$CONFIGURATION/libfuzzy_matcher.a \
--ios target/aarch64-apple-ios/$CONFIGURATION/libfuzzy_matcher.a \
--name FuzzyMatcher

cp target/universal-macos/$CONFIGURATION/libfuzzy_matcher.a FuzzyMatcher/RustXcframework.xcframework/macos-arm64_x86_64/libfuzzy_matcher.a
mv FuzzyMatcher/RustXcframework.xcframework FuzzyMatcher/FuzzyMatcherRust.xcframework
sed -i '' 's/RustXcframework/FuzzyMatcherRust/g' FuzzyMatcher/Package.swift
cp /tmp/fuzzy-matcher.swift FuzzyMatcher/Sources/FuzzyMatcher/fuzzy-matcher.swift
