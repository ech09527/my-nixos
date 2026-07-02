{ config, pkgs, lib, ... }:

let
  nvm = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "nvm";
    version = "0.40.3";
    src = pkgs.fetchFromGitHub {
      owner = "nvm-sh";
      repo = "nvm";
      rev = "v${version}";
      hash = "sha256-s36EQojnNKm4x410nllC3nbnzzwcLZCKSP3DkJPpjjo=";
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/nvm
      cp -r $src/* $out/share/nvm/
      runHook postInstall
    '';
  };
in
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
     initialHashedPassword = lib.mkForce null;
     hashedPassword = "$6$AtoFoSGUt8LQtRwj$Fe8tUWma2D6GUWlR5a7.pAa/wI6OW62wSIzYRpQOouPxNFJeixwyOqesntn4TRGE6WFmB3VpH8Ma7Yuc5UPOA0";
  # 在这里配置 SSH 公钥
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYam+IxrgQ48DBG0zJpBUhtDRr/h0xmiwRQW0AnDe1krT+JQv1iAd9HJIuo4eSBQeViifhtlMO6IRWNwKSFHnQs/ZUpycTHrim0cdkTE2KnIcl+LX8hVwVmx+iVJgSef94QwxeBSGpq+p6UZgOHQkMbOGvqC+yRxcNxhY+wU7+sixUq2HQc7+MFfnirFQvMbEZw0lEMHa/IcQWZwjgcRhgeuELFTVFO68DL1JkrW0g5oUGXIqOqj5zxW0yrSFGNcZaoeovwDNgJQjzGGZQM8KXFBGsvSOWmVcC1xbEamWitmqvcGsSVHgXRqpi6InKqM3TDrTJc5zJvj/f0NP9d41cilggtZlaRDtHO2KJ/aWb68DCi9B7yey1KiJMonMQClPdsUvB4F/M5hMoJNt0fB/CRsjRxHldx5wHejt2A51nMatXoxsakmSZk3B1+sjMjfp9gYrPn2NxZBxH/HsBKx36BdKQsyZw4FZp8KzAL2v38z621661PPaG6H1avpNxKEc="
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvTB/TkQgqfrUEIYdpgZd13icD4oHkkzXa4T23SPTgN8z542JfKyqoWf51juWg8+n08oN2lEoj3Mv/vvAcaoRvQ6/04/Pezs7JICf+0EkPI6KDRMjxsm+RFPn5p1wt2L+mtf2CW4jxaYyniiCGKM79SJZ9wM++BOVY8WTJAbHi0C45kwhfvA4X4dlS9Ukm1YcvHAMqyK1vowZ0AeA1pCFenqVThjpj/gdEWGXgxSyrd3HNlXpdbGctVPQYred53oUNzPyDo+d+LivBBvZ2IFyf+v+kG9qiz+Hr735JDkU99TGIRL2Xw6OU2dsDyKIAg8piR0qyDHvAdazpvWs+VWdp admin@win10ltsc"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFGgkAcYZEIEK1qWBgiWY1nNdN2yEHuRV4Eb4qoJn4O5kaNjLCyK2891brP6emI9Ae9dWLZ1/RTAnn3+jG0PqRqPULIIlXNfA+drSbgKJN2pYhKSQGrAcoiwaRmRvsxlNdkTxsn12Wg0xez0UH37AMgjdJvGW53iXNSxXxaes74wv0OFqed23Nbtk2rZXngdf9g/BiU7lCNIZgDCZT/HR0bVBtjqC3iFJcaLtDIZs5c+kWbKtdS+1K/Vd+QWm6xc3214BtwsWbFm9jPEHcgo71KJaYwKnhcjXbO/Y7ysC4+A0gRd5hSqZkIn7iRBvuHlZjzIUj/9x/QmW4+6GNervN admin@win10ltsc2"
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

  # uv / pip / npm / nvm 国内镜像（环境变量兜底，配置文件为主）
  environment.variables = {
    UV_DEFAULT_INDEX = "https://pypi.tuna.tsinghua.edu.cn/simple";
    UV_PYTHON_INSTALL_MIRROR = "https://mirror.nju.edu.cn/github-release/astral-sh/python-build-standalone/";
    PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
    NPM_CONFIG_REGISTRY = "https://registry.npmmirror.com";
    NVM_DIR = "/root/.nvm";
    NVM_NODEJS_ORG_MIRROR = "https://npmmirror.com/mirrors/node";
  };

  environment.etc."pip.conf".text = ''
    [global]
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    trusted-host = pypi.tuna.tsinghua.edu.cn
  '';

  environment.etc."bashrc.local".text = ''
    export NVM_DIR="/root/.nvm"
    export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"
    if [ -s "${nvm}/share/nvm/nvm.sh" ]; then
      . "${nvm}/share/nvm/nvm.sh"
    fi
  '';

  systemd.tmpfiles.rules = [
    "d /root/.config/uv 0755 root root -"
    "L+ /root/.config/uv/uv.toml - - - - ${./config/uv.toml}"
    "f /root/.npmrc 0644 root root - registry=https://registry.npmmirror.com"
    "d /root/.nvm 0755 root root -"
  ];

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
    uv
    nvm
    codex
    curl
    opencode
    antigravity-cli
    openssl
    vault-bin
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
