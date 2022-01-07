/* Undo all sorts of things that happen in NixOS, to reduce closure
   size and store path count for docker.

   This is not sustainable.
 */
args@{ config, lib, pkgs, ... }: {

  disabledModules = [
    ("system/boot/kexec.nix")
    ("misc/crashdump.nix")
    ("tasks/swraid.nix")
    ("profiles/base.nix")
    ("tasks/filesystems.nix")
    # ("system/boot/")
  ];


  # publish args for hacking
  config.system.build.args = args;

  # fake tasks/filesystems
  options.system.fsPackages =
    lib.mkOption { type = lib.types.listOf lib.types.unspecified; };
  options.boot.specialFileSystems =
    lib.mkOption { type = lib.types.attrs; };
  options.boot.supportedFilesystems =
    lib.mkOption { type = lib.types.listOf lib.types.unspecified; };
  options.fileSystems =
    lib.mkOption { type = lib.types.listOf lib.types.unspecified; default = []; };
  config.system.build.fileSystems = [];
  config.system.build.earlyActivationScript = "";
  config.system.build.earlyMountScript = pkgs.writeText "empty" "";
  # end fake tasks/filesystems

  config.services.nscd.enable = false;
  config.system.nssModules = lib.mkForce []; # consequence of nscd.enable = false
  config.networking.dhcpcd.enable = false;
  config.security.wrappers = lib.mkForce {};
  config.security.polkit.enable = false;
  config.security.sudo.enable = false;

  config.networking.firewall.enable = false;
}
