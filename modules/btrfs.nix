{ lib, config, pkgs, ... }:

let
  cfg = config.settings.fileSystems.btrfs;

  fd = lib.getExe pkgs.fd;
  btrfs = lib.getExe' pkgs.btrfs-progs "btrfs";
in
{
  options = {
    settings.fileSystems.btrfs = {
      enable = lib.mkEnableOption "our custom BTRFS module";

      commonOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      snapshots = {
        enable = lib.mkEnableOption "btrfs snapshots";

        configs = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({ name, config, lib, ... }: {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
              };
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };
              volume = lib.mkOption {
                type = lib.types.str;
              };
              frequency = lib.mkOption {
                type = lib.types.str;
              };
              startAt = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              numberToKeep = lib.mkOption {
                type = lib.types.str;
              };
              destDir = lib.mkOption {
                type = lib.types.str;
              };
            };

            config.name = lib.mkDefault name;
          }));
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    settings.fileSystems.btrfs.commonOptions = [
      # ACL is enabled by default.
      "defaults"
      # https://wiki.archlinux.org/title/fstab#atime_options
      "lazytime"
      "noatime"
      "compress=zstd:1"
      "autodefrag"
      # We disable discard here, it is taken care of by an fstrim timer,
      # as recommended by the btrfs manpage.
      "nodiscard"
      "nodev"
      "nosuid"
    ];

    services.btrfs.autoScrub = {
      enable = true;
      # Only scrub one of the subvolumes, it will scrub the whole FS.
      fileSystems = [ "/nix" ];
    };

    systemd =
      let
        mkUnits = { name, volume, frequency, startAt, numberToKeep, destDir, ... }:
          let
            unitName = "${name}-snapshots";
            destPath = "/vol/snapshots/${destDir}/${frequency}";
          in
          {
            services."${unitName}" = {
              description = ''Make a snapshot of ${destDir}'';
              serviceConfig = {
                Type = "oneshot";
              };
              script = ''
                mkdir --parent "${destPath}"
                ${btrfs} subvolume snapshot -r \
                  "/${volume}" \
                  "${destPath}/$(date --iso-8601=seconds)"

                for path in $(${fd} --max-depth=1 . "${destPath}" | \
                              sort | \
                              head -n -${numberToKeep}); do
                  echo "Removing subvolume: ''${path} ..."
                  ${btrfs} subvolume delete "''${path}"
                done
              '';
              restartIfChanged = false;
            };
            timers."${unitName}" = {
              wantedBy = [ "timers.target" ];
              timerConfig = {
                OnCalendar = if startAt != null then startAt else frequency;
                Persistent = true;
              };
            };
          };
      in
      lib.compose [
        (lib.foldl (res: cfg: lib.recursiveUpdate res (mkUnits cfg)) { })
        lib.attrValues
        lib.filterEnabled
        (lib.optionalAttrs cfg.snapshots.enable)
      ]
        cfg.snapshots.configs;
  };
}
