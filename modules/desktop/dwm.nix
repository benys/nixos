{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.dwm;
    configDir = config.dotfiles.configDir;
    binDir = config.dotfiles.binDir;
in {
  options.modules.desktop.dwm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    
    environment.systemPackages = with pkgs; [
      lightdm
      dunst
      libnotify
      dwmblocks
    ];

    nixpkgs = {
      overlays = [
        (self: super: {
          dwm = super.dwm.overrideAttrs (oldattrs: {
            src = fetchGit {
              url = "https://github.com/benys/dwm";
              rev = "442c7bbca96cb0c84d94f8fce827c7d4a92bd1ee";
            }; 
          });

          dwmblocks = super.dwmblocks.overrideAttrs (oldattrs: {
            src = fetchGit {
              url = "https://github.com/benys/dwmblocks";
              rev = "113db5edcc697318d6a491f736ecb896050d8f25";
            }; 
          });
        })
      ]; 
    };

    services = {
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+dwm";
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
        };
        windowManager = {
          dwm.enable = true;
        };
      };
    };

    systemd.user.services."dunst" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
    };
    
    systemd.user.services."dwmblocks" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      path = [ "${binDir}/statusbar" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dwmblocks}/bin/dwmblocks";
    };
    
  };
}
