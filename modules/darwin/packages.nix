{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    orbstack
    pinentry_mac
    (pulumi.withPackages (p: [ p.pulumi-nodejs ]))
    # Twilio uses nodejs-slim by default; keep it on the patched system runtime.
    (twilio-cli.override { nodejs-slim = pkgs.nodejs-security; })
  ];
}
