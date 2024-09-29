{
  pkgs,
  meta,
  ...
}: let
  monitorLine = monitor:
    builtins.concatStringsSep "," [
      monitor.name
      "${monitor.width}x${monitor.height}@${builtins.toString monitor.framerate}"
      "0x0"
      (builtins.toString monitor.scale)
    ];

  lidScript = let
    monitor = builtins.elemAt meta.monitors 0;
  in
    pkgs.writeShellScript "lidswitch.sh"
    ''
      if grep open /proc/acpi/button/lid/LID0/state; then
          hyprctl keyword monitor "${monitorLine monitor}"
      else
          if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
              hyprctl keyword monitor "${monitor.name}, disable"
          else
            systemctl suspend
          fi
      fi
    '';
in {
  enable = true;
  settings = {
    "$mod" = "SUPER";
    exec-once = ["ags"];
    exec = [
      ''gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"   # for GTK3 apps''
      ''gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"   # for GTK4 apps''
      ''gsettings set org.gnome.desktop.interface cursor-theme "Banana-Catppuccin-Mocha"''
      ''gsettings set org.gnome.desktop.interface cursor-size 64''
    ];
    xwayland = {
      force_zero_scaling = true;
    };
    general = {
      gaps_out =
        if meta.name == "karasu"
        then 0
        else 30;
    };
    input = {
      follow_mouse = 1;
      touchpad = {
        natural_scroll = true;
        disable_while_typing = true;
        tap-to-click = false;
        middle_button_emulation = false;
      };
      sensitivity = 0;
    };
    "misc:middle_click_paste" = false;
    env = [
      "QT_QPA_PLATFORMTHEME,qt6ct"
      "HYPRCURSOR_SIZE,${builtins.toString meta.cursor}"
      "XCURSOR_SIZE,${builtins.toString meta.cursor}"
    ];
    monitor = map monitorLine meta.monitors;
    bezier = [
      "easeOutBack,0.34,1.56,0.64,1"
      "easeInBack,0.36,0,0.66,-0.56"
      "easeInCubic,0.32,0,0.67,0"
      "easeInOutCubic,0.65,0,0.35,1"
    ];
    animation = [
      "windowsIn,1,5,easeOutBack,popin"
      "windowsOut,1,5,easeInBack,popin"
      "fadeIn,0"
      "fadeOut,1,10,easeInCubic"
      "workspaces,1,4,easeInOutCubic,slide"
    ];
    bind =
      [
        "$mod, Return, exec, alacritty"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, S, exec, grim"
        "$mod, F, exec, firefox"
        "$mod, E, exec, nautilus"
        "$mod, V, togglefloating"
        "$mod, R, exec, wofi --show drun"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"
        "$mod, T, togglegroup"
        "$mod+ALT, J, changegroupactive, f"
        "$mod+ALT, K, changegroupactive, f"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
      ]
      ++ (
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );
    bindl = [
      '', switch:Lid Switch, exec, ${lidScript}''
    ];
  };
  extraConfig = ''
  '';
}
