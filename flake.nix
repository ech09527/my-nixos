{
  description = "My NixOS Flake";

  inputs = {
    # 官方 NixOS 稳定版源（可根据需要调整版本，如 nixos-25.11 或 nixos-unstable）
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # 这里的 "my-nixos-hostname" 记得改成你的实际主机名（hostname）
    nixosConfigurations.default1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # 如果是 ARM 架构则改为 "aarch64-linux"
      modules = [
        # 1. 引入你给出的配置
        ./configuration.nix

        # 2. 提示：通常你还需要引入硬件配置文件，否则系统可能无法正常引导
        # ./hardware-configuration.nix
      ];
    };
  };
}
