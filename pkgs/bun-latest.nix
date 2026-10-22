{ bun, fetchurl }:

# Keep nixpkgs' packaging and Darwin fixups, but track upstream releases.
bun.overrideAttrs (final: {
  version = "1.4.4";
  src = fetchurl {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v${final.version}/bun-darwin-aarch64.zip";
    hash = "sha256-wkDX8My5DCY6hJ/NsJt+5iYw2SE0jtaq/ahrnVd7xRA=";
  };
})
