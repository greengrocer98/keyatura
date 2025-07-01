#!/usr/bin/env bash

set -euxo pipefail

# Requirements:
# 1. https://zmk.dev/docs/development/setup
# 2. checkout zmk repo to feat/pointers-move-scroll on petejohansson's repo

build_and_copy () {
    local side=$1
    rm -rf $CURRENT_DIR/build/$side
    export NRF_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb/nrf"
    export NRFXLIB_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb/nrfxlib"
    export ZMK_ESB_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb"
    export ZMK_RGBLED_WIDGET="$HOME/zmk_modules/zmk-rgbled-widget"
    export ZMK_MODULE_DIRS="${ZMK_ESB_MODULE_DIRS};${NRF_MODULE_DIRS};${NRFXLIB_MODULE_DIRS};${ZMK_RGBLED_WIDGET}"
    west build \
        -p -b nice_nano_v2 \
        -d "$CURRENT_DIR/build/$side" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=keyatura_$side \
        -DZMK_EXTRA_MODULES="${ZMK_MODULE_DIRS}" \

    cp "$CURRENT_DIR/build/$side/zephyr/zmk.uf2" "$CURRENT_DIR/build/$side/keyatura_$side.uf2"
}

build_dongle () {
    local side=dongle
    rm -rf $CURRENT_DIR/build/$side
    export NRF_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb/nrf"
    export NRFXLIB_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb/nrfxlib"
    export ZMK_ESB_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb"
    export ZMK_RGBLED_WIDGET="$HOME/zmk_modules/zmk-rgbled-widget"
    export ZMK_MODULE_DIRS="${ZMK_ESB_MODULE_DIRS};${NRF_MODULE_DIRS};${NRFXLIB_MODULE_DIRS};${ZMK_RGBLED_WIDGET}"
    west build \
        -p -b nice_nano_v2 \
        -S studio-rpc-usb-uart \
        -S zmk-usb-logging \
        -d "$CURRENT_DIR/build/$side" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=keyatura_$side \
        -DZMK_EXTRA_MODULES="${ZMK_MODULE_DIRS}"

    cp "$CURRENT_DIR/build/$side/zephyr/zmk.uf2" "$CURRENT_DIR/build/$side/keyatura_$side.uf2"
}

build_reset () {
    rm -rf $CURRENT_DIR/build/reset
    west build \
        -p -b nice_nano_v2 \
        -S studio-rpc-usb-uart \
        -d "$CURRENT_DIR/build/reset" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=settings_reset

    cp "$CURRENT_DIR/build/reset/zephyr/zmk.uf2" "$CURRENT_DIR/build/reset/reset.uf2"
}

CURRENT_DIR="$(pwd)"

DEFAULTZMKAPPDIR="$HOME/zmk-esb/zmk/"   
ZMK_APP_DIR="$DEFAULTZMKAPPDIR/app"

cd $DEFAULTZMKAPPDIR && source .venv/bin/activate && cd -

mkdir -p $CURRENT_DIR/build

pushd $ZMK_APP_DIR

# build_and_copy left
# build_and_copy right
build_dongle 
build_reset

deactivate

popd