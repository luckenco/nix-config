{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.2.101";

  sources = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-hDFTjb2ZN5JA9Vi0i3ecZR1miwbXk8hzEa1TLEOVpOI=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-TC1uezENUN2p8bsBQ/BplQ26toAhw46QIq77cyq9Mxk=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-JVYpnN7Tf4HlTAJCDPp/Gi35/qtypEWGmg9VluFDszM=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "grok-cli-latest: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "grok-cli-latest";
  inherit version;

  src = fetchurl {
    url = "https://x.ai/cli/grok-${version}-${source.platform}";
    inherit (source) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/grok"
    ln -s "$out/bin/grok" "$out/bin/agent"

    runHook postInstall
  '';

  meta = {
    description = "AI agent CLI powered by Grok";
    homepage = "https://x.ai";
    license = lib.licenses.unfree;
    mainProgram = "grok";
    platforms = lib.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
