{ pkgs, ... }:
let
  piAgentsMd = pkgs.writeText "pi-agent-AGENTS.md" (builtins.readFile ./pi/AGENTS.md);
  json = pkgs.formats.json { };
  managedPiSettings = json.generate "pi-agent-managed-settings.json" {
    defaultTools = [ "+codemode" ];
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
    mcpServers = {
      linear = {
        url = "https://mcp.linear.app/mcp";
        exposure = "deferred";
      };
      chrome-devtools = {
        command = "${pkgs.bun}/bin/bunx";
        args = [
          "chrome-devtools-mcp@latest"
          "--no-usage-statistics"
          "--no-performance-crux"
          "--redact-network-headers"
        ];
        exposure = "deferred";
        description = "Debug Chrome pages, JavaScript, network requests, and browser performance.";
      };
    };
  };
in
{
  home-manager.sharedModules = [
    (
      { config, lib, ... }:
      {
        home.activation.writePiPackageSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          (
            set -e
            if [ -v DRY_RUN ]; then
              exit 0
            fi

            target="${config.home.homeDirectory}/.pi/agent/settings.json"
            mkdir -p "$(dirname "$target")"
            tmp="$(${pkgs.coreutils}/bin/mktemp "$target.XXXXXX")"
            trap 'rm -f "$tmp"' EXIT

            if [ -f "$target" ]; then
              ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$target" "${managedPiSettings}" > "$tmp"
            else
              ${pkgs.coreutils}/bin/cp "${managedPiSettings}" "$tmp"
            fi
            ${pkgs.coreutils}/bin/chmod 0644 "$tmp"
            ${pkgs.coreutils}/bin/mv -f "$tmp" "$target"

            ${pkgs.coreutils}/bin/install -m 0644 "${managedPiMcp}" "${config.home.homeDirectory}/.pi/agent/mcp.json"
            install -Dm 0644 "${piAgentsMd}" "${config.home.homeDirectory}/.pi/agent/AGENTS.md"
          )
        '';
      }
    )
  ];
}
