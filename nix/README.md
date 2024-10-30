# Building from source with nix

Just `nix develop` to pull in llvm etc.

Then

```sh
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -GNinja -DZIG_NO_LIB=ON
ninja install
```

outputs `stage3/bin/zig` to build directory.

Then

```sh
stage3/bin/zig build -p stage4 -Denable-llvm -Dno-lib
```

builds a debug build into `stage4/bin/zig`.

Can do a test of standard library with:

```sh
stage4/bin/zig build test-std -Dskip-release -Dskip-non-native
```

These instructions are from
https://github.com/ziglang/zig/wiki/Contributing#directly-testing-the-standard-library-with-zig-test
