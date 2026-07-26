{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.2.112";

  sources = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-XPBf5nCxgYVh2vdWa1gKXea4EUkWZJnWEHLklkC1QaQ=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-0h8aqrp/KTDbDvfVqdw/gUqUxUryCOCR9yojnKwCujk=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-woZxEvfYk2YSP+aKVaI9+wJ9NgL8W1uc1cCA2stKJQM=";
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
