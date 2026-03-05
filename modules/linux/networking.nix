{ lib, ... }: {
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  networking.networkmanager.dns = "none";

  networking.firewall.enable = lib.mkDefault true;
}
