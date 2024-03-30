# modules/browser/brave.nix --- https://publishers.basicattentiontoken.org
#
# A FOSS and privacy-minded browser.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.work.work;
in {
  options.modules.desktop.work.work = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      teams-for-linux
    ];

    environment.systemPackages = with pkgs; [
      networkmanager-openconnect
      networkmanager-fortisslvpn 
      networkmanagerapplet
    ];

    networking.networkmanager.plugins = [
      pkgs.networkmanager-fortisslvpn
      pkgs.networkmanager-openconnect
    ];
  };
}
