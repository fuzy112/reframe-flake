# reframe-flake
A NixOS module for ReFrame

## Usage

In flake.nix:

```nix
{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
		reframe = {
			url = "github:fuzy112/reframe-flake";
			inputs.nixpkgs.follows = "nixpkgs";  # optional
		};
	};

	outputs = {
	   nixpkgs,
	   reframe,
	   ...
	}:
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

In configuration.nix:

```nix
{ config, pkgs, ... }:

{
	services.reframe = {
		enable = true;
		instances.default = {
			enable = true;
			settings = {
				reframe = {
				rotation = 0;
				desktop-width = 0;
				desktop-height = 0;
				monitor-x = 0;
				monitor-y = 0;
				default-width = 0;
				default-height = 0;
				cursor = true;
				fps = 5;
			};
			vnc = {
				port = 5933;
				type = "libvncserver";
				password = "123456";
			};
		 };
	  };
   };
}
```
