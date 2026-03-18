lib:
lib.nixosSystem' (
  {
    config,
    lib,
    pkgs,
    ...
  }:
  let
    inherit (lib) collectNix remove;
  in
  {
    imports = collectNix ./. |> remove ./default.nix;

    type = "server";

    # Bootloader - GRUB for VPS compatibility
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";

    networking.hostName = "nixos-vps";

    # Tailscale for secure access
    services.tailscale.enable = true;

    # Hardened SSH
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };

    # SSH public key
    users.users.morpheus.openssh.authorizedKeys.keys = [
      (builtins.readFile ../../keys/morpheus.pub)
    ];

    # Fail2ban for additional security
    services.fail2ban = {
      enable = true;
      maxretry = 5;
    };

    # Enable firewall on VPS
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      trustedInterfaces = [ "tailscale0" ];
    };
  }
)
