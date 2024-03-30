{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.gnome;
    configDir = config.dotfiles.configDir;
in {
  options.modules.desktop.gnome = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libnotify
    ];

    services = {
      xserver = {
        enable = true;
        displayManager = {
          gdm.enable = true;
        };
        desktopManager = {
          gnome.enable = true;
        };
      };
    };
  };
}
