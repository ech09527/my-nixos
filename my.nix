{ config, pkgs, lib, ... }:

{

   programs.nix-ld.enable = true;
   programs.nix-ld.libraries = with pkgs; [
        ];

   services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";         # 允许 root 登录
      PasswordAuthentication = true;   # 允许密码认证
    };
  };
  time.timeZone = "Asia/Shanghai";
  nixpkgs.config.allowUnfree = true;

  users.users.root = {

     hashedPassword = "$6$AtoFoSGUt8LQtRwj$Fe8tUWma2D6GUWlR5a7.pAa/wI6OW62wSIzYRpQOouPxNFJeixwyOqesntn4TRGE6WFmB3VpH8Ma7Yuc5UPOA0";
  # 在这里配置 SSH 公钥
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYam+IxrgQ48DBG0zJpBUhtDRr/h0xmiwRQW0AnDe1krT+JQv1iAd9HJIuo4eSBQeViifhtlMO6IRWNwKSFHnQs/ZUpycTHrim0cdkTE2KnIcl+LX8hVwVmx+iVJgSef94QwxeBSGpq+p6UZgOHQkMbOGvqC+yRxcNxhY+wU7+sixUq2HQc7+MFfnirFQvMbEZw0lEMHa/IcQWZwjgcRhgeuELFTVFO68DL1JkrW0g5oUGXIqOqj5zxW0yrSFGNcZaoeovwDNgJQjzGGZQM8KXFBGsvSOWmVcC1xbEamWitmqvcGsSVHgXRqpi6InKqM3TDrTJc5zJvj/f0NP9d41cilggtZlaRDtHO2KJ/aWb68DCi9B7yey1KiJMonMQClPdsUvB4F/M5hMoJNt0fB/CRsjRxHldx5wHejt2A51nMatXoxsakmSZk3B1+sjMjfp9gYrPn2NxZBxH/HsBKx36BdKQsyZw4FZp8KzAL2v38z621661PPaG6H1avpNxKEc="
  ];
  };
  networking.extraHosts = ''
    100.78.7.4 redpanda-0
  '';
  virtualisation.docker.enable = true;

  # virtualisation.docker.storageDriver = "zfs";

  virtualisation.docker.daemon.settings = {
    # 1. 配置多个公共/私有加速镜像源（注意：请替换为 2026 年当前可用或你自建的有效加速地址）
    registry-mirrors = [
      "https://dkm.nocsdn.com"
    ];


    # 3. 你还可以在这里添加其他常规的 daemon.json 参数
    log-driver = "json-file";
    log-opts = {
      max-size = "10m";
      max-file = "3";
    };
  };

  # 1. 安装 Vim 软件包
  environment.systemPackages = with pkgs; [
    vim
    git
    # distrobox
    # steam-run
    gh
    docker-compose
    restic
    cursor-cli
    tea
  ];

  virtualisation.podman = {
    enable = false;
    defaultNetwork.settings.dns_enabled = true;
  };
  environment.etc."containers/registries.conf".text = lib.mkForce ''
    unqualified-search-registries = ["docker.io"]

    [[registry]]
    location = "docker.io"

    [[registry.mirror]]
    location = "dkm.nocsdn.com"
  '';
  # 2. 设置国内软件包源（二进制缓存）和启用 Flakes 实验特性
  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];

    # 开启实验性功能（推荐）
    experimental-features = [ "nix-command" "flakes" ];
  };
}
