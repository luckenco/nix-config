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

    # Temporary: Fabric is incompatible with Invoke 3 (https://github.com/fabric/fabric/issues/2376).
    # Remove this input and use pkgs.azure-cli once it builds from the main nixpkgs input.
    nixpkgs-azure-cli.url = "github:nixos/nixpkgs/319e4cebef10cbb636c6ea392137b52ad105336a";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
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
    planetscale-tap = {
      url = "github:planetscale/homebrew-tap";
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

      checks.${system} = {
        nodejs =
          let
            nodejs = inputs.self.darwinConfigurations.mbp.pkgs.nodejs-security;
          in
          assert pkgs.lib.versionAtLeast nodejs.version "24.22.1";
          pkgs.runCommand "nodejs-runtime-check"
            {
              nativeBuildInputs = [
                pkgs.stdenv.cc
                nodejs.python
              ];
            }
            ''
              export HOME="$TMPDIR"
              test "$(${nodejs}/bin/node --version)" = "v${nodejs.version}"
              test -f ${nodejs}/include/node/node_api.h
              # npm and Corepack must find the patched runtime without relying on PATH.
              PATH= ${nodejs}/bin/npm --version
              PATH= ${nodejs}/bin/npx --version
              PATH= ${nodejs}/bin/corepack --version

              # Build an addon offline with an empty header cache and no host Xcode.
              cat > binding.gyp <<'EOF'
              {"targets": [{"target_name": "addon", "sources": ["addon.c"]}]}
              EOF
              cat > addon.c <<'EOF'
              #include <node_api.h>
              napi_value init(napi_env env, napi_value exports) { return exports; }
              NAPI_MODULE(NODE_GYP_MODULE_NAME, init)
              EOF
              ${nodejs}/bin/node ${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js rebuild
              ${nodejs}/bin/node -e 'require("./build/Release/addon.node")'
              touch "$out"
            '';

        updates =
          pkgs.runCommand "update-behavior-check"
            {
              src = ./.;
              nativeBuildInputs = with pkgs; [
                jq
                perl
              ];
            }
            ''
              cd "$src"
              bash scripts/test-updates
              touch "$out"
            '';

        pi-settings =
          let
            config = inputs.self.darwinConfigurations.mbp.config;
            hm = config.home-manager.users.${config.system.primaryUser};
          in
          pkgs.runCommand "pi-settings-check"
            {
              nativeBuildInputs = [ pkgs.jq ];
              ACTIVATE_PI = pkgs.writeShellScript "activate-pi-settings" (
                builtins.replaceStrings [ hm.home.homeDirectory ] [ "$HOME" ]
                  hm.home.activation.writePiPackageSettings.data
              );
            }
            ''
              bash ${./scripts/test-pi-settings}
              touch "$out"
            '';

        deadnix =
          pkgs.runCommand "deadnix-check"
            {
              src = ./.;
              nativeBuildInputs = [ pkgs.deadnix ];
            }
            ''
              cd "$src"
              deadnix --fail .
              touch "$out"
            '';

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

        shellcheck =
          pkgs.runCommand "shellcheck-check"
            {
              src = ./scripts;
              nativeBuildInputs = [ pkgs.shellcheck ];
            }
            ''
              cd "$src"
              shellcheck *
              touch "$out"
            '';

        shfmt =
          pkgs.runCommand "shfmt-check"
            {
              src = ./scripts;
              nativeBuildInputs = [ pkgs.shfmt ];
            }
            ''
              cd "$src"
              shfmt -d -i 2 -ci *
              touch "$out"
            '';
      };
    };
}
