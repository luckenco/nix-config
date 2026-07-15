{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    orbstack
    pinentry_mac
    pscale
    (pulumi.withPackages (p: [ p.pulumi-nodejs ]))
    twilio-cli
  ];
}
