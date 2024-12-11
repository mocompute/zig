pkgs:

rec {
  release = import ./zig-release.nix;

  zig = pkgs.callPackage ./zig.nix { inherit release; };

  devShell = pkgs.mkShell {
    nativeBuildInputs = zig.nativeBuildInputs ++ (with pkgs; [
      bashInteractive
      ninja
    ]);

    inherit (zig)
      buildInputs
      hardeningDisable;

    inZigDevEnv = 1;
  };

}
