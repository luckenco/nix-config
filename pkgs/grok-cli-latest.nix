{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.2.60";

  sources = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-Gfcrn1nhKUqJvUX1UQPNUXLDKYZMOXjp/nu+YhY2HMY=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-fE6A9qCyBnQmoqhfD/4JE6d8+YB+qXQ8X2CDG9/99F4=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-uJrNAdPYSd+fdjQ4XKICq+XxCC3VdmHfoM8gTBnL3tM=";
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
