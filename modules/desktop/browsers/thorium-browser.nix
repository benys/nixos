# modules/browser/brave.nix --- https://publishers.basicattentiontoken.org
#
# A FOSS and privacy-minded browser.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.browsers.thorium-browser;
in {
  options.modules.desktop.browsers.thorium-browser = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      my.thorium-browser
    ];
  };
}
