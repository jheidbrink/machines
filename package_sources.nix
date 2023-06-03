{
  nixpkgs2305_source = builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/0f7f5ca1cdec8dea85bb4fa60378258171d019ad.tar.gz";  # 2023-05-29 nixos-23.05 branch
      sha256 = "sha256:0cnv56gmw7ina9gfqp02d9k0526rwnwq34jmcfpl92vawx42arvz";
    };
}
