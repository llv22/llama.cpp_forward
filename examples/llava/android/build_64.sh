#!/bin/bash
cmake ../../../../ \
-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
-DCMAKE_BUILD_TYPE=Release \
-DANDROID_ABI=arm64-v8a \
-DANDROID_PLATFORM=android-23 \
-DCMAKE_C_FLAGS=-march=armv8.4a+dotprod

make clean && make -j4
