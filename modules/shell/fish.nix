{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.fish;
    configDir = config.dotfiles.configDir;
in {
  options.modules.shell.fish = with types; {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    users.defaultUserShell = pkgs.fish;

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };

    environment.systemPackages = with pkgs; [
      fishPlugins.done
      fishPlugins.fzf
      fishPlugins.forgit
      fishPlugins.pure
      fzf
    ];

    env = {
    };

    home.configFile = {
      
    };

    system.userActivationScripts.cleanupZgen = ''
    '';
  };
}
