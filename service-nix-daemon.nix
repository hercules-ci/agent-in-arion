{ pkgs, lib, ... }:
{
  # ENABLING THIS WILL MOST LIKELY DAMAGE THE HOST.
  # You're probably looking for service.useHostNixDaemon instead of this module.
  service.useHostStore = lib.mkForce false; # DID YOU READ THE COMMENT?

  nixos.configuration = { pkgs, lib, ...}: {
    boot.postBootCommands = ''
        # Background: https://kinvolk.io/blog/2018/04/towards-unprivileged-container-builds/#the-exception-of-procfs-and-sysfs
        for dir in $(${pkgs.gawk}/bin/awk '/\/proc\// { print $5 }' /proc/1/mountinfo); do
          echo "Exposing $dir"
          umount "$dir"
        done
    '';
    systemd.sockets.nix-daemon.enable = true;
    systemd.services.nix-daemon.enable = true;
    # Use a non-default range in order to decrease the likelyhood of getting killed by the host nix-daemon
    ids.uids.nixbld = lib.mkForce 9000;
    ids.gids.nixbld = lib.mkForce 9000;
  };
  service.devices = [ "/dev/kvm" ];
  service.capabilities.SYS_ADMIN = true;
  out.service.security_opt = [ "seccomp=unconfined" ];
}
