#!/usr/bin/env bash
# Source this file in every development terminal.
golden_setup_root="${GOLDENPERCEPTION_ENV_DIR:-/workspace/.goldenperception-env}"
export CARGO_HOME="$golden_setup_root/cargo"
export RUSTUP_HOME="$golden_setup_root/rustup"
export RUSTUP_TOOLCHAIN=1.99.0
export CARGO_TARGET_DIR="$golden_setup_root/target"
export PATH="$CARGO_HOME/bin:$PATH"
export CARGO_BUILD_JOBS=4
export npm_config_cache="$golden_setup_root/npm-cache"
