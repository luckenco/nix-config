{
  description = "macOS development configuration";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    warn-dirty = false;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew management
    brew-src = {
      url = "github:Homebrew/brew";
      flake = false;
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.follows = "brew-src";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      darwinConfigurations.mbp = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.default
          ./modules/common
          ./modules/darwin
          ./hosts/mbp
        ];
      };

      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system}.formatting =
        pkgs.runCommand "nixfmt-check"
          {
            src = ./.;
            nativeBuildInputs = with pkgs; [
              findutils
              nixfmt
            ];
          }
          ''
            cd "$src"
            find . -name '*.nix' -print0 | xargs -0 nixfmt --check
            touch "$out"
          '';
    };
}
