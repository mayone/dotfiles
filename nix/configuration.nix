# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  # You can reference to `unstable_pkgs.{package_name}` if you want latest available version for that package
  unstable_pkgs = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable) { config = config.nixpkgs.config; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # For this to work you first need to add a channel for home-manager:
    # > nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    # > nix-channel --update
    # <home-manager/nixos>
  ];

  # Bootloader.config
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-d78a1364-9440-4ddd-969c-3e48c6ccf80c".device = "/dev/disk/by-uuid/d78a1364-9440-4ddd-969c-3e48c6ccf80c";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

 # Networking
  networking = {
    # Example:
    hostName = "FE-25408-BTDL-waynejeng-P14s-NixOS";
    # Enable network management through NetworkManager
    networkmanager.enable = true;
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    firewall = {
      # Open ports in the firewall.
      allowedTCPPorts = [ 443 80 ];
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # Here is a trick to let our device route all traffice through Wireguard
      # cf: https://nixos.wiki/wiki/WireGuard
      # wireguard trips rpfilter up
      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "zh_TW.UTF-8";
      LC_IDENTIFICATION = "zh_TW.UTF-8";
      LC_MEASUREMENT = "zh_TW.UTF-8";
      LC_MONETARY = "zh_TW.UTF-8";
      LC_NAME = "zh_TW.UTF-8";
      LC_NUMERIC = "zh_TW.UTF-8";
      LC_PAPER = "zh_TW.UTF-8";
      LC_TELEPHONE = "zh_TW.UTF-8";
      LC_TIME = "zh_TW.UTF-8";
    };

    # Mandarin/Chinese input method (Can be detected by Gnome)
    # cf: https://nixos.wiki/wiki/IBus
    #inputMethod = {
    #  enabled = "ibus";
    #  ibus.engines = with pkgs.ibus-engines; [ rime libpinyin ];
    #};
    # Another input method available (fcitx5-chewing)
    # cf: https://nixos.org/manual/nixos/stable/#module-services-input-methods
    # cf: https://nixos.org/manual/nixos/stable/#module-services-input-methods-fcitx
    # cf: https://nixos.wiki/wiki/Fcitx5
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chewing
        fcitx5-gtk
      ];
    };
    # And then install GNOME extension manually
    # cf: https://extensions.gnome.org/extension/261/kimpanel/
    # The 3rd step is to add the relevant settings to environment.system packages
    # Just take a look when go through environment.system settings
  };

  # System services
  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      # Display manager
      displayManager = {
        # Gnome's display manager
        gdm.enable = true;
        # Tweak to make Display Link docks accept more monitors
        sessionCommands = ''
          xrandr --setprovideroutputsource 2 0
        '';
      };

      # Gnome Desktop Environment
      desktopManager = {
        gnome.enable = true;
      };

      # Keyboard Layout
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };

    # Printing server CUPS
    printing = {
      enable = true;
      drivers = [
        pkgs.foomatic-db
        pkgs.foomatic-db-ppds
      ];
    };

    # Pipewire sound server
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # HTTP Server
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      # other Nginx options
      virtualHosts."localhost.com" = {
        #enableACME = true;
        forceSSL = false;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;" +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;"
          ;
        };
      };
    };

    udev.packages = [
      # Used to set udev rules to access ST-LINK devices from probe-rs
      pkgs.openocd
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Virtualization (Containers and VMs)
  virtualisation = {
    containers.enable = true;
    docker.enable = true;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wayne = {
    isNormalUser = true;
    description = "Wayne";
    # Dialout group is used for USB serial coms: https://nixos.wiki/wiki/Serial_Console
    extraGroups = [ "networkmanager" "wheel" "dialout" "wireshark" "docker" ];
    packages = with pkgs; [
      # You can add any nixpkgs here
      # This config by default put all pkgs available at the system level, but you can move some here
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow dynamic linking
  programs.nix-ld.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # ===== Browser ===== #
    chromium
    firefox

    # ===== Communication ===== #
    discord
    element-desktop
    #element-desktop-wayland
    #teams-for-linux
    #telegram-desktop
    # For line us this chrome extensions:
    ## https://chromewebstore.google.com/detail/line/ophjlpahpchlmihnnnihgmmeilfjmjjc?hl=zh-TW

    # ===== Terminal ===== #
    alacritty
    alacritty-theme
    ghostty
    fzf-zsh
    neofetch
    oh-my-zsh
    zsh

    # ===== Note ===== #
    appflowy

    # ===== Media ===== #
    ffmpeg
    gimp-with-plugins
    inkscape-with-extensions
    libreoffice-fresh
    # wpsoffice
    libsForQt5.kdenlive
    obs-studio
    vlc

    # ===== Networking ===== #
    nettools
    wireshark

    # ===== System Tools ===== #
    gnome-tweaks
    gparted
    mkcert
    # Issues related to binary blobs security
    #https://github.com/NixOS/nixpkgs/issues/404663
    # See the following Issues for context:
    # https://github.com/ventoy/Ventoy/issues/2795
    # https://github.com/ventoy/Ventoy/issues/3224
    #ventoy-full
    # Used to check if an app is using Xwayland or Wayland
    curl
    docker-compose
    ttf-tw-moe
    wget
    xorg.xeyes
    zip

    # ===== DEV ===== #
    git
    gcc
    gnumake
    postman
    # Postman Open-Source Alternative
    #hoppscotch
    nixpkgs-fmt

    #saleae-logic-2
    #stm32cubemx

    # ===== Node.js ===== #
    nodejs
    pnpm

    # ===== Color Management ===== #
    #gnome.gnome-color-manager

    # ===== IDE ===== #
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    (unstable_pkgs.vscode-with-extensions.override {
      vscode = unstable_pkgs.vscodium; # or unstable_pkgs.vscode
      vscodeExtensions = with unstable_pkgs.vscode-extensions; [
        adpyke.codesnap
        streetsidesoftware.code-spell-checker
        #serayuzgur.crates
        editorconfig.editorconfig
        usernamehw.errorlens
        tamasfe.even-better-toml
        fill-labs.dependi
        mhutchie.git-graph
        yzhang.markdown-all-in-one
        shd101wyy.markdown-preview-enhanced
        davidanson.vscode-markdownlint
        pkief.material-icon-theme
        zhuangtongfa.material-theme
        bbenoist.nix
        arrterian.nix-env-selector
        jnoortheen.nix-ide
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        rust-lang.rust-analyzer
        gruntfuggly.todo-tree
        #vscodevim.vim
        #asvetliakov.vscode-neovim
        github.vscode-github-actions
        ecmel.vscode-html-css
        redhat.vscode-yaml
        bradlc.vscode-tailwindcss
        esbenp.prettier-vscode
        charliermarsh.ruff
        alefragnani.bookmarks
        alefragnani.project-manager

      ] ++ unstable_pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        #{
        #  name = "dioxus";
        #  publisher = "DioxusLabs";
        #  version = "0.6.0";
        #  sha256 = "UYMJf0F8YjH1s7szIdTDG7t31/xjryD3wxogQM4ywOU=";
        #}
        {
          name = "gitless";
          publisher = "maattdd";
          version = "11.7.2";
          sha256 = "rYeZNBz6HeZ059ksChGsXbuOao9H5m5lHGXJ4ELs6xc=";
        }
        {
          name = "probe-rs-debugger";
          publisher = "probe-rs";
          version = "0.24.2";
          sha256 = "1Gs5D5was/ZOZQrVD3/UiRm5bb12vGIl60AZV2EnazQ=";
        }
        {
          name = "remote-explorer";
          publisher = "ms-vscode";
          version = "0.5.2024121609";
          sha256 = "IwRImqqun483C7yTfs+dAhAHpihxjjULVbuSHut8XPA=";
        }
        {
          name = "vscode-todo-highlight";
          publisher = "wayou";
          version = "1.0.5";
          sha256 = "CQVtMdt/fZcNIbH/KybJixnLqCsz5iF1U0k+GfL65Ok=";
        }
        {
          name = "wokwi-vscode";
          publisher = "wokwi";
          version = "2.6.0";
          sha256 = "epWN+VQbXVb+mQCBJ3rvgmgemrMCliJE3AmPmw7g0IA=";
        }
      ];
    })

    # ===== Input Method (fcitx5-chewing) ===== #
    gnomeExtensions.kimpanel

    # ===== Custom ===== #
    # A cat clone with syntax highlighting and Git intergration
    bat
    # A modern, maintained replacement for ls
    eza
    # An interactive process viewer
    htop
    # Command-line wrapper for git that makes you better at GitHub
    hub
  ];

  # Global user shell config
  users.defaultUserShell = pkgs.zsh;
  # ZSH config
  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "bureau";
        plugins = [
          "git"
          "npm"
          "history"
          "node"
          "rust"
          "deno"
        ];
      };
    };
  };

  fonts = {
    fontDir.enable = true;
    packages = with unstable_pkgs; [
      font-awesome
      nerd-fonts.caskaydia-cove
      nerd-fonts.fira-code
      nerd-fonts.meslo-lg
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      source-code-pro
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [
          "Noto Color Emoji"
        ];
        monospace = [
          "Source Code Pro"
          "Noto Sans Mono TC"
          "DejaVu Sans Mono"
        ];
        sansSerif = [
          "Noto Sans TC"
          "DejaVu Sans"
        ];
        serif = [
          "Noto Serif TC"
          "DejaVu Serif"
        ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05";
  # ===== Customized ===== #
  # Power Management
  # systemd.sleep.extraConfig = ''
  #   AllowSuspend=no
  #   AllowHibernation=yes
  #   AllowHybridSleep=no
  #   AllowSuspendThenHibernate=no
  # '';
}
