{ config, lib, ... }: lib.mkIf config.isDarwin {
  security.pam.services.sudo_local.touchIdAuth = true;

  networking.applicationFirewall = {
    enable = true;
    blockAllIncoming = false;
    allowSigned = true;
    allowSignedApp = true;
    enableStealthMode = true;
  };
}
