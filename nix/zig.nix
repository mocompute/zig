{ lib
, stdenv
, fetchFromGitHub
, cmake
, coreutils
, llvmPackages_19
, libgcc
, libxml2
, zlib
, release
}:

let
  llvmPackages = llvmPackages_19;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zig";
  inherit (release) version;

  src = fetchFromGitHub {
    owner = "mocompute";
    repo = "zig";
    rev = release.src.rev;
    hash = release.src.hash;
  };

  # Zig's build looks at /usr/bin/env to detect the dynamic linker (ld-linux).
  # This path doesn't exist in the Nix build environment.
  postPatch = ''
    substituteInPlace lib/std/zig/system.zig \
      --replace "/usr/bin/env" "${coreutils}/bin/env"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libgcc.lib # work around https://github.com/ziglang/zig/issues/18612 (libstdc++.so not found in rpath)
    libxml2
    zlib
  ] ++ (with llvmPackages; [
    libclang
    lld
    llvm
  ]);

  cmakeFlags = [
    "-DZIG_VERSION=${release.version}"
    "-DZIG_TARGET_MCPU=baseline"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  hardeningDisable = [ "all" ];

  preConfigure = ''
    export ZIG_GLOBAL_CACHE_DIR=$TMP/zig-cache;
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    srcDir=$TMP/$sourceRoot
    $out/bin/zig test --cache-dir "$TMP/zig-test-cache" -I $srcDir/test $srcDir/test/behavior.zig

    runHook postInstallCheck
  '';

  passthru = { inherit llvmPackages; };

  meta = {
    description = "General-purpose programming language and toolchain for maintaining robust, optimal and reusable software";
    homepage = "https://ziglang.org";
    changelog = "https://ziglang.org/download/${finalAttrs.version}/release-notes.html";
    license = lib.licenses.mit;
    mainProgram = "zig";
    platforms = lib.platforms.unix;
  };
})
