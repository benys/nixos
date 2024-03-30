{ pkgs, config, lib, ... }:
{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = {
    desktop = {
      dwm.enable = true;
      apps = {
        rofi.enable = true;
        # godot.enable = true;
      };
      browsers = {
        default = "firefox";
        firefox.enable = true;
      };
      gaming = {
      };
      media = {
        documents.enable = true;
      };
      term = {
        default = "xst";
        st.enable = true;
      };
      vm = {
        qemu.enable = true;
      };
    };
    dev = {
      cc.enable = true;
    };
    editors = {
      default = "nvim";
      vim.enable = true;
    };
    shell = {
      vaultwarden.enable = false;
      direnv.enable = true;
      git.enable    = true;
      gnupg.enable  = true;
      tmux.enable   = true;
      zsh.enable    = false;
    };
    services = {
      ssh.enable = true;
      docker.enable = true;
    };
    theme.active = "alucard";
  };

  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
  ];

  user.packages = with pkgs; [
  ];

  ## Local config
  programs.ssh.startAgent = true;
  services.openssh.startWhenNeeded = true;

  # networking.useDHCP = true;
  networking.networkmanager.enable = true;

  # networking.wireless.enable = true;
  time.timeZone = "Europe/Warsaw";

  environment = {
    persistence = {
      "/vol/persisted" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib"
          "/etc/secureboot"
          "/etc/NetworkManager/system-connections"
        ];
        users.kamil = {
          files = [
            ".config/gh/hosts.yml"
            ".config/monitors.xml"
          ];
          directories = [
            ".config/exercism"
            ".config/goa-1.0"
            ".config/gtk-3.0"
            ".config/gtk-4.0"
            ".config/keepassxc"
            ".config/nautilus"
            ".config/nvim/spell"
            ".config/vlc"
            ".config/weechat"
            ".local"
            ".ssh"
            "Documents"
            "Projects"
            "dotfiles"
            "nixos-config"
          ];
        };
      };
      "/vol/volatile" = {
        hideMounts = true;
        users.kamil = {
          files = [
            ".bash_history"
            ".python_history"
          ];
          directories = [
            ".cabal"
            ".cache"
            ".config/autostart"
            ".config/chromium"
            ".config/evolution"
            ".config/pcloud"
            ".config/Slack"
            ".config/Signal"
            ".config/transmission"
            ".config/via-nativia"
            ".ghc"
            ".gnupg"
            ".mozilla"
            ".pcloud"
            "Downloads"
          ];
        };
      };
    };
  }

  disko.devices =
    let
      mainDisk = "/dev/disk/by-path/virtio-pci-0000:07:00.0";
    in
    {
      nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "nosuid"
            "nodev"
            "noatime"
            "size=1G"
            "mode=0755"
          ];
        };
      };
      # https://git.sr.ht/~r-vdp/nixos-config
      disk.main = {
        device = mainDisk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "1G";
              type = "c12a7328-f81f-11d2-ba4b-00a0c93ec93b";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [
                  "-F 32"
                  "-n ESP"
                ];
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "relatime"
                  "umask=0077"
                  "noauto"
                  "x-systemd.automount"
                  "x-systemd.idle-timeout=5min"
                ];
              };
            };
            primary = {
              priority = 2;
              size = "100%";
              # Linux LUKS
              type = "ca7d7ccb-63ed-4c53-861c-1742536059cc";
              content = {
                type = "luks";
                name = "decrypted";
                extraFormatArgs = [ "--type luks2" ];
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "--label nixos"
                  ];
                  subvolumes =
                    let
                      mountOptions = config.settings.fileSystems.btrfs.commonOptions;
                    in
                    {
                      "nix" = {
                        mountpoint = "/nix";
                        inherit mountOptions;
                      };
                      "snapshots" = {
                        mountpoint = "/vol/snapshots";
                        inherit mountOptions;
                      };
                      "persisted" = {
                        mountpoint = "/vol/persisted";
                        inherit mountOptions;
                      };
                      "volatile" = {
                        mountpoint = "/vol/volatile";
                        inherit mountOptions;
                      };
                    };
                };
              };
            };
          };
        };
      };
    };
}
