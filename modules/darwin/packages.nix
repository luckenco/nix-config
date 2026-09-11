{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    orbstack
    pinentry_mac
    (pulumi.withPackages (p: [ p.pulumi-nodejs ]))
    twilio-cli
  ];
}
