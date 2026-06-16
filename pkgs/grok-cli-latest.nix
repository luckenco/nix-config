{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.2.54";

  sources = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-lUh6VbkBWQMqX0o285NbNN5zPKjkFXCi/qeMoQbYcDw=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-WBbTWEmz4WflNUIpMKgt9mqpKNqpS/2v6UFmyz6J8I8=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-SmRlkVVfuKrGym4GfhLGMCv+fUROOf/94oj90KTDJ/s=";
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
