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
mkdir -p ./target/universal-macos/debug

lipo \
    ./target/aarch64-apple-darwin/debug/libfuzzy_matcher.a \
    ./target/x86_64-apple-darwin/debug/libfuzzy_matcher.a -create -output \
    ./target/universal-macos/debug/libfuzzy_matcher.a
