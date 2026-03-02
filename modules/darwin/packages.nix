{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    aerospace
    brave
    orbstack
    pinentry_mac
  ];

  # Update npm-only packages during rebuild
  system.activationScripts.postActivation.text = ''
    echo "Updating pi-coding-agent..."
    ${pkgs.bun}/bin/bun install -g @mariozechner/pi-coding-agent@latest 2>/dev/null || true
  '';
}
