# modules/dev/dotnet.nix --- dotnet
# inspiracja: https://manuelplavsic.ch/articles/flutter-environment-with-nix/

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
with import <nixpkgs> {
  config = {
    android_sdk.accept_license = true;
    allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "androidsdk"
    ];
  };
};

let devCfg = config.modules.dev;
    cfg = devCfg.android;
    androidComposition = androidenv.composeAndroidPackages {
      buildToolsVersions = [ "30.0.3" ];
      includeEmulator = true;
      platformVersions = [ "34" "33" "32" ];
      includeSources = true;
      includeSystemImages = false;
      systemImageTypes = [ "google_apis_playstore" ];
      abiVersions = [ "x86_64" ];
      cmakeVersions = [ "3.10.2" ];
      includeNDK = true;
      ndkVersions = ["22.0.7026061"];
      useGoogleAPIs = true;
      useGoogleTVAddOns = false;
      includeExtras = [
        "extras;google;gcm"
      ];
      extraLicenses = [
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "android-sdk-license"
          "android-sdk-preview-license"
          "google-gdk-license"
          "intel-android-extra-license"
          "intel-android-sysimage-license"
          "mips-android-sysimage-license"            ];

    };
    androidSdk = androidComposition.androidsdk;
in {
  options.modules.dev.android = {
    enable = mkBoolOpt true;
  };

  config = mkMerge [
    (mkIf cfg.enable {

      users.users.${config.user.name} = {
        extraGroups = ["adbusers" "kvm"];
      };
      user.packages = with pkgs; [
        androidSdk
        flutter
        jetbrains.idea-ultimate
        qemu_kvm
        gradle
        jdk11
      ];

      environment = {
        sessionVariables = {
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          FLUTTER_ROOT = flutter;
          JAVA_HOME = jdk11.home;
          DART_ROOT = "${flutter}/bin/cache/dart-sdk";
        };
      };
    })
  ];
}
