#!/bin/bash
if [ -z "$RUSTUP_TOOLCHAIN" ]; then
    export RUSTUP_TOOLCHAIN="stable"  # "stable" or "nightly"
fi

if [ -z "$RUSTUP_PROFILE" ]; then
    export RUSTUP_PROFILE="release"  # "debug" or "release"
fi

# Build Time Autovars
SCRIPT=`realpath "$0"`
SCRIPT_DIR=`dirname "$SCRIPT"`
PROJECT_ROOT=$SCRIPT_DIR

# Install Vars
WASM_BINDGEN_VERSION=`cat $PROJECT_ROOT/Cargo.toml | grep '^wasm-bindgen' | head -n1 | cut -d'"' -f2 | tr -d '\n'`

echo "Project Root: $PROJECT_ROOT"
echo "RUSTUP_TOOLCHAIN: $RUSTUP_TOOLCHAIN - Build RUSTUP_PROFILE: $RUSTUP_PROFILE"
echo "This will install tools as if it's continous integration..."
echo "This, however, will not install things from your package manager like python's \`pip\`..."

if [[ "$(read -e -p 'Continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]; then
    cd $PROJECT_ROOT

    echo "Install Rust..."
    mkdir -p $PROJECT_ROOT/tools
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > $PROJECT_ROOT/tools/rust.sh
    chmod +x $PROJECT_ROOT/tools/rust.sh
    $PROJECT_ROOT/tools/rust.sh -y
    source "$HOME/.cargo/env"

    echo "Install Rust Targets..."
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN x86_64-unknown-linux-gnu
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN x86_64-pc-windows-gnu
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN wasm32-unknown-unknown
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN x86_64-unknown-linux-musl
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN armv7-linux-androideabi
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN aarch64-linux-android
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN i686-linux-android
    rustup target add --RUSTUP_TOOLCHAIN $RUSTUP_TOOLCHAIN x86_64-linux-android

    echo "Install Wasm-Bindgen Tools..."
    if [ $RUSTUP_PROFILE == "release" ]; then
        cargo +$RUSTUP_TOOLCHAIN install wasm-bindgen-cli --version $WASM_BINDGEN_VERSION
    else
        cargo +$RUSTUP_TOOLCHAIN install wasm-bindgen-cli --version $WASM_BINDGEN_VERSION --debug
    fi

    echo "Install Wasm Optimization Tools..."
    if [ $RUSTUP_PROFILE == "release" ]; then
        cargo +$RUSTUP_TOOLCHAIN install wasm-opt
    else
        cargo +$RUSTUP_TOOLCHAIN install wasm-opt --debug
    fi

    echo "Install Wasm Source Mapping Tools..."
    if [ $RUSTUP_PROFILE == "release" ]; then
        cargo +$RUSTUP_TOOLCHAIN install cargo-wasm2map
    else
        cargo +$RUSTUP_TOOLCHAIN install cargo-wasm2map --debug
    fi

    echo "Install Customized Cargo AppImage Tools..."
    wget https://github.com/lexi-the-cute/appimagetool/releases/download/continuous/appimagetool-x86_64 -O $PROJECT_ROOT/tools/appimagetool
    chmod +x $PROJECT_ROOT/tools/appimagetool
    if [ $RUSTUP_PROFILE == "release" ]; then
        cargo +$RUSTUP_TOOLCHAIN install --git https://github.com/foxgirl-labs/cargo-appimage
    else
        cargo +$RUSTUP_TOOLCHAIN install --git https://github.com/foxgirl-labs/cargo-appimage --debug
    fi

    echo "Install Cargo NDK Tools..."
    if [ $RUSTUP_PROFILE == "release" ]; then
        cargo +$RUSTUP_TOOLCHAIN install cargo-ndk
    else
        cargo +$RUSTUP_TOOLCHAIN install cargo-ndk --debug
    fi

    echo "Install Pre-Commit Checks..."
    pip install pre-commit
    pre-commit install

    echo "Install Itch.io Butler"
    wget https://broth.itch.zone/butler/linux-amd64/LATEST/archive/default -O $PROJECT_ROOT/tools/butler-linux-amd64.zip
fi
