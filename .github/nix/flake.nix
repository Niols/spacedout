{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    opam-nix.url = "github:tweag/opam-nix";
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, self', inputs', ... }: {
        formatter = pkgs.nixfmt;

        packages.default = self'.packages.dancelor;

        packages.dancelor =
          let
            scope = inputs'.opam-nix.lib.buildOpamProject { inherit pkgs; } "spacedout"
              ../../. {
                merlin = "*";
                ocaml-base-compiler = "*";
                ocaml-lsp-server = "*";
                ocp-indent = "*";
                utop = "*";
              };
          in (scope.spacedout // { inherit scope; });
      };

      perInput = system: flake:
        if flake ? lib.${system} then { lib = flake.lib.${system}; } else { };
    };
}
