{ pkgs, lib, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "wlr-which-key";
  version = "unstable-2023-04-19";

  src = pkgs.fetchFromGitHub {
    owner = "MaxVerevkin";
    repo = "wlr-which-key";
    rev = "e98aa54cdfd5850026621d7b5718840181dd95da";
    sha256 = "sha256-dH/MYtYuu/yiEjeAmtIICL9fldoAZyZtluELGmMubHU=";
  };

  cargoSha256 = "sha256-GyJcnFvkEhrdAv8+0VMZMA6Z72EFmhZsfUuCG5iDkEw=";

  # buildType = "debug";  # This was an attempt to skip rust-analyzer to fix the build
}
