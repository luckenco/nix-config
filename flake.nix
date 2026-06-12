{
  description = "NixOS and nix-darwin configuration";

  nixConfig = {
    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
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

    sops-nix = {
      url = "github:Mic92/sops-nix";
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
    inputs@{ nixpkgs, nix-darwin, ... }:
    let
      inherit (builtins) readDir;
      inherit (nixpkgs.lib)
        attrsToList
        const
        genAttrs
        groupBy
        listToAttrs
        mapAttrs
        ;

      lib' = nixpkgs.lib.extend (const (const nix-darwin.lib));
      lib = lib'.extend (import ./lib inputs);

      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = genAttrs supportedSystems (
        system:
        import nixpkgs {
          inherit system;
        }
      );

      # Host auto-discovery + classification.
      # Each hosts/<name>/default.nix calls darwinSystem' or nixosSystem'.
      # We group the evaluated results (the big attrset returned by the
      # system builders) to produce darwinConfigurations vs nixosConfigurations
      # in the flake outputs without having to list hosts explicitly.
      #
      # The predicate relies on the shape of the evaluated system value for
      # the Linux hosts. This has always worked in practice (see nix flake show).
      # The comment exists purely for future maintainability / clarity.
      hostsByType =
        readDir ./hosts
        |> mapAttrs (name: const (import ./hosts/${name} lib))
        |> attrsToList
        |> groupBy (
          { value, ... }:
          if value ? class && value.class == "nixos" then "nixosConfigurations" else "darwinConfigurations"
        )
        |> mapAttrs (const listToAttrs);
    in
    hostsByType
    // {
      inherit inputs lib;

      formatter = mapAttrs (_: pkgs: pkgs.nixfmt-tree) forAllSystems;

      checks = mapAttrs (_: pkgs: {
        formatting =
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
      }) forAllSystems;
    };
}
