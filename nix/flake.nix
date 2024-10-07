# following examples at https://github.com/erikarvstedt/nix-zig-build
{
  description = "Flake for building Zig from source.";

  inputs = {
    nixpkgs.url = "github:mocompute/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ...}:
    let
      systems = ["x86_64-linux" "aarch64-linux" ];
    in
      flake-utils.lib.eachSystem systems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          outputs = import ./outputs.nix pkgs;
        in
          {
            packages = {
              default = outputs.zig;
              inherit (outputs)
                zig;
            };

            devShells.default = outputs.devShell;
          });
}
