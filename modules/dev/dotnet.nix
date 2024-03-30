# modules/dev/dotnet.nix --- dotnet
#

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let devCfg = config.modules.dev;
    cfg = devCfg.dotnet;
in {
  options.modules.dev.dotnet = {
    enable = mkBoolOpt true;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      user.packages = with pkgs; [
        (with dotnetCorePackages; combinePackages [
          sdk_6_0
          sdk_7_0
          sdk_8_0
        ])
        jetbrains.rider
        (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rider [
          "github-copilot" 
          ])
      ];
    })
  ];
}
