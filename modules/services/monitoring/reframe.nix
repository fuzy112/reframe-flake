{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.reframe;
  settingsFormat = pkgs.formats.ini { };
  instanceType = lib.types.submodule (
    { config, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = ''
            Name of the instance.
          '';
          default = config._module.args.name;
        };

        enable = lib.mkEnableOption ''
          Enable this reframe server instance.
        '';

        settings = lib.mkOption {
          type = settingsFormat.type;
          description = ''
            Configuration settings for the instance.
          '';
          default = { };
          example = lib.literalExpression ''
            {
              reframe = {
                rotation = 0;
                desktop-width = 0;
                desktop-height = 0;
                monitor-x = 0;
                monitor-y = 0;
                default-width = 0;
                default-height = 0;
                cursor = true;
                fps = 30;
              };
              vnc = {
                port = 5933;
                type = "libvncserver";
              };
            };
          '';
        };
      };
    }
  );
in
{
  options.services.reframe = {
    enable = lib.mkEnableOption ''
      Enable reframe server.
    '';
    package = lib.mkPackageOption pkgs "reframe" { };

    instances = lib.mkOption {
      type = lib.types.attrsOf instanceType;
      description = ''
        Instances of reframe servers to run.
      '';
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ cfg.package ];

    users = {
      users.reframe = {
        isSystemUser = true;
        group = "reframe";
      };
      groups.reframe = { };
    };

    environment.etc = lib.mapAttrs' (
      _name:
      { name, settings, ... }:
      lib.nameValuePair "reframe/${name}.conf" {
        source = settingsFormat.generate "${name}.conf" settings;
      }
    ) cfg.instances;

    systemd.services = lib.mapAttrs' (
      _name:
      { name, enable, ... }:
      lib.nameValuePair "reframe-server@${name}" {
        inherit enable;
        overrideStrategy = "asDropin";
      }
    ) cfg.instances;

    systemd.sockets = lib.mapAttrs' (
      _name:
      { name, enable, ... }:
      lib.nameValuePair "reframe@${name}" {
        inherit enable;
        overrideStrategy = "asDropin";
      }
    ) cfg.instances;
  };
}
