{ pkgs, ... }:
let
  piAgentsMd = pkgs.writeText "pi-agent-AGENTS.md" (builtins.readFile ./pi/AGENTS.md);
  json = pkgs.formats.json { };
  managedPiSettings = json.generate "pi-agent-managed-settings.json" {
    packages = [
      {
        source = "git:github.com/luckenco/pinnacle";
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
        source = "npm:@plannotator/pi-extension";
      }
    ];
  };
  managedPiMcp = json.generate "pi-agent-managed-mcp.json" {
    mcpServers.linear = {
      url = "https://mcp.linear.app/mcp";
      exposure = "deferred";
    };
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

          ${pkgs.coreutils}/bin/install -m 0644 "${managedPiMcp}" "${config.home.homeDirectory}/.pi/agent/mcp.json"
          install -Dm 0644 "${piAgentsMd}" "${config.home.homeDirectory}/.pi/agent/AGENTS.md"
        '';
      }
    )
  ];
}
