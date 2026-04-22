{ pkgs, ... }:
{
  # Neovim config is still owned by the stowed dotfiles repo for now.
  environment.systemPackages = [ pkgs.neovim ];
}
