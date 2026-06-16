{ lib, pkgs, ... }:
let
  managedPiSettings = (pkgs.formats.json { }).generate "pi-agent-managed-settings.json" {
    packages = [
      {
        source = "git:git@github.com:luckenco/pinnacle";
        extensions = [
          "extensions/*.ts"
          "!extensions/todos.ts"
        ];
      }
      {
        source = "npm:pi-web-access";
      }
      {
        source = "npm:@tmustier/pi-raw-paste";
      }
      {
        source = "npm:pi-btw";
      }
      {
        source = "npm:@juicesharp/rpiv-todo";
      }
    ];
  };
in
{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      {
        home.activation.writePiPackageSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          target="${config.home.homeDirectory}/.pi/agent/settings.json"
          mkdir -p "$(dirname "$target")"

          if [ -f "$target" ]; then
            tmp="$(${pkgs.coreutils}/bin/mktemp)"
            ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$target" "${managedPiSettings}" > "$tmp"
            ${pkgs.coreutils}/bin/install -m 0644 "$tmp" "$target"
            rm -f "$tmp"
          else
            ${pkgs.coreutils}/bin/install -m 0644 "${managedPiSettings}" "$target"
          fi
        '';
      }
    )
  ];
}
