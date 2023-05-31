{ config, pkgs, lib, ... }:
{
  # from https://nixos.wiki/wiki/Nvidia
  nixpkgs.config.allowUnfree = true;  # NVIDIA drivers are unfree
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia.modesetting.enable = true;

  # from https://github.com/grahamc/nixos-cuda-example/blob/master/configuration.nix and 
  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };
  environment.systemPackages = [ pkgs.cudatoolkit ];
}

