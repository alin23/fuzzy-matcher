# build-rust.sh

#!/bin/bash

set -e

THISDIR=$(dirname $0)
cd $THISDIR

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"
export MACOSX_DEPLOYMENT_TARGET=11.0
# Build the project for the desired platforms:
cargo build --target x86_64-apple-darwin --release
cargo build --target aarch64-apple-darwin --release
mkdir -p ./target/universal-macos/$1

lipo \
    ./target/aarch64-apple-darwin/$1/libfuzzy_matcher.a \
    ./target/x86_64-apple-darwin/$1/libfuzzy_matcher.a -create -output \
    ./target/universal-macos/$1/libfuzzy_matcher.a

swift-bridge-cli create-package \
--bridges-dir ./generated \
--out-dir FuzzyMatcher \
--macos target/universal-macos/$1/libfuzzy_matcher.a \
--name FuzzyMatcher

cp target/universal-macos/$1/libfuzzy_matcher.a FuzzyMatcher/RustXcframework.xcframework/macos-arm64_x86_64/libfuzzy_matcher.a