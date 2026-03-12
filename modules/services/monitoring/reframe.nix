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

            See https://github.com/AlynxZhou/reframe for detailed documentation.

            Key sections:
            - reframe: Core display settings (card, connector, rotation, fps, etc.)
            - vnc: VNC server configuration (port, password, type)
          '';
          default = { };
          example = lib.literalExpression ''
            {
              reframe = {
                # DRM card selection (empty = auto-detect)
                card = "";
                # Connector selection (empty = auto-detect)
                connector = "";
                # Display rotation: 0, 90, 180, 270
                rotation = 0;
                desktop-width = 0;
                desktop-height = 0;
                monitor-x = 0;
                monitor-y = 0;
                default-width = 0;
                default-height = 0;
                cursor = true;
                # Wake up display on connection
                wakeup = true;
                fps = 30;
              };
              vnc = {
                port = 5933;
                # Empty means no password
                password = "";
                # VNC implementation: "libvncserver" or "neatvnc"
                type = "libvncserver";
              };
            }
          '';
        };
      };
    }
  );
in
{
  options.services.reframe = {
    enable = lib.mkEnableOption ''
      Enable reframe server - a VNC server for DRM/KMS Linux systems.

      Provides remote desktop access by sharing the physical display via VNC.
      Supports both libvncserver and neatvnc backends.
    '';

    package = lib.mkPackageOption pkgs "reframe" { };

    instances = lib.mkOption {
      type = lib.types.attrsOf instanceType;
      description = ''
        Instances of reframe servers to run.

        Each instance creates a systemd service and socket pair:
        - reframe-server@<instance>.service
        - reframe@<instance>.socket
        - reframe-streamer@<instance>.service

        Multiple instances can serve different displays or configurations.
      '';
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Install systemd service and socket files from the package
    systemd.packages = [ cfg.package ];

    # Create reframe user and group for service permissions
    users = {
      users.reframe = {
        isSystemUser = true;
        group = "reframe";
        description = "ReFrame Remote Desktop Service";
      };
      groups.reframe = { };
    };

    # Generate configuration files for each instance
    # Permissions: root:reframe 0750 as required by reframe >= v1.9.0
    environment.etc = lib.mapAttrs' (
      _name:
      { name, settings, ... }:
      lib.nameValuePair "reframe/${name}.conf" {
        source = settingsFormat.generate "${name}.conf" settings;
        mode = "0640";
        user = "root";
        group = "reframe";
      }
    ) cfg.instances;

    # Configure systemd services for reframe-server
    systemd.services = lib.mapAttrs' (
      _name:
      { name, enable, ... }:
      lib.nameValuePair "reframe-server@${name}" {
        inherit enable;
        overrideStrategy = "asDropin";
      }
    ) cfg.instances;

    # Configure systemd sockets for reframe
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
