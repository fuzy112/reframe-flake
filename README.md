# reframe-flake

A NixOS module for ReFrame - A VNC server for DRM/KMS Linux systems.

## Features

- Remote desktop access via VNC
- Multiple instance support
- Support for both libvncserver and neatvnc backends
- Multi-monitor support
- Runtime plugin architecture
- Improved authentication and security

## Installation

### Using flakes

In your `flake.nix`:

```nix
{
  inputs = {
	nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
	reframe = {
	  url = "github:fuzy112/reframe-flake";
	  inputs.nixpkgs.follows = "nixpkgs";  # optional
	};
  };

  outputs = { nixpkgs, reframe, ... }:
  {
	nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
	  modules = [
		./configuration.nix
		reframe.nixosModules.reframe
		{ nixpkgs.overlays = [ reframe.overlays.reframe ]; }
	  ];
	};
  }
}
```

## Configuration

In your `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  services.reframe = {
	enable = true;

	instances.default = {
	  enable = true;
	  settings = {
		reframe = {
		  # DRM card selection (empty = auto-detect)
		  # Available cards can be found in /sys/class/drm/
		  card = "";

		  # Connector selection (empty = auto-detect)
		  # Available connectors can be found in /sys/class/drm/
		  connector = "";

		  # Display rotation: 0, 90, 180, 270 (clockwise)
		  rotation = 0;

		  # Multi-monitor desktop dimensions
		  # Set to logical size of virtual desktop for multi-monitor setups
		  desktop-width = 0;
		  desktop-height = 0;

		  # Monitor position (for multi-monitor setups)
		  monitor-x = 0;
		  monitor-y = 0;

		  # Default display size (0 = monitor size)
		  default-width = 0;
		  default-height = 0;

		  # Enable DRM cursor plane
		  cursor = true;

		  # Wake up display on VNC connection
		  wakeup = true;

		  # Target FPS
		  fps = 30;
		};

		vnc = {
		  # VNC server port
		  port = 5933;

		  # VNC password (empty = no password)
		  password = "";

		  # VNC implementation type:
		  # - "libvncserver": Stable, widely compatible
		  # - "neatvnc": More efficient encoding (may be less stable)
		  type = "libvncserver";
		};
	  };
	};
  };
}
```

### Multiple Instances

You can run multiple reframe instances to serve different displays:

```nix
services.reframe = {
  enable = true;

  instances = {
	display0 = {
	  enable = true;
	  settings = {
		reframe = {
		  card = "card0";
		  connector = "HDMI-A-1";
		  port = 5933;
		};
	  };
	};

	display1 = {
	  enable = true;
	  settings = {
		reframe = {
		  card = "card0";
		  connector = "DP-1";
		  port = 5934;
		};
	  };
	};
  };
};
```

## Service Architecture

Each instance creates three systemd units:

- `reframe-server@<instance>.service` - Main VNC server (runs as `reframe` user)
- `reframe@<instance>.socket` - Socket activation for VNC connections
- `reframe-streamer@<instance>.service` - Display streamer (runs as `root` for DRM access)

## Finding Display Configuration

To find available cards and connectors:

```bash
# List available DRM cards
ls /sys/class/drm/

# Check connected displays
cat /sys/class/drm/card0-HDMI-A-1/status
```

## Security Notes

- Configuration files are stored in `/etc/reframe/` with permissions `0750` (root:reframe)
- The streamer service runs as root to access DRM devices
- The server service runs as the `reframe` system user
- Socket files use `0660` permissions with `reframe` group ownership

## License

BSD-3-Clause (same as upstream ReFrame)
