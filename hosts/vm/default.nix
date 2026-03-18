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

    type = "desktop";

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "vm";

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # VM-specific packages
    environment.systemPackages = with pkgs; [
      xclip
    ];

    # Graphics and X11
    hardware.graphics.enable = true;

    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
    };

    # VMware guest support
    virtualisation.vmware.guest.enable = true;

    # Auto-login for local VM
    services.getty.autologinUser = "morpheus";

    # VMware shared folders
    fileSystems."/mnt/hgfs" = {
      device = ".host:/";
      fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
      options = [
        "umask=22"
        "uid=1000"
        "gid=100"
        "allow_other"
        "auto_unmount"
        "defaults"
      ];
    };

    # Auto-start X on tty1
    home-manager.users.morpheus.programs.zsh.profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec startx
      fi
    '';
  }
)
