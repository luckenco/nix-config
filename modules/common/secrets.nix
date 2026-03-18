{ config, lib, ... }:
{
  sops = lib.mkIf config.my.secrets.enable {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "${config.my.machine.homeDir}/.config/sops/age/keys.txt";
    validateSopsFiles = false;
  };
}
