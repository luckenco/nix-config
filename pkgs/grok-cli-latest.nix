{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "1.0.44";
in
stdenvNoCC.mkDerivation {
  pname = "grok-cli-latest";
  inherit version;

  src = fetchurl {
    url = "https://x.ai/cli/grok-${version}-macos-aarch64";
    hash = "sha256-tjepNMIu5IDMEzp4NxL1q9hFrof3sKpkbCIK89Z/fCg=";
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
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
