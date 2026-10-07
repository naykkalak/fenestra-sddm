#!/bin/bash
# Fenestra SDDM - installer
# https://github.com/naykkalak/fenestra-sddm - GPL-3.0
#
#   sudo bash install.sh              install (or update) the theme
#   sudo bash install.sh --uninstall  remove everything this script installed
#
# Installs:
#   /usr/share/sddm/themes/fenestra-sddm            the theme
#   /etc/sddm.conf.d/zz-fenestra-sddm.conf          virtual keyboard + network indicator (Wayland greeter)
#   Backgrounds/ writable by administrators (wheel or sudo group), to add your own login backgrounds
#   optional: random background at every boot (fenestra-sddm-random-bg service)
#   shortcuts in your Pictures folder: <Wallpapers>/<Login screen> and <Wallpapers>/<Desktop>

set -euo pipefail

THEME_NAME="fenestra-sddm"
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/$THEME_NAME"
DEST="/usr/share/sddm/themes/$THEME_NAME"
CONF_SRC="$HERE/extras/zz-fenestra-sddm.conf"
CONF_DEST="/etc/sddm.conf.d/zz-fenestra-sddm.conf"
BG_SCRIPT_SRC="$HERE/extras/fenestra-sddm-random-bg"
BG_SCRIPT="/usr/local/sbin/fenestra-sddm-random-bg"
BG_SERVICE_SRC="$HERE/extras/fenestra-sddm-random-bg.service"
BG_SERVICE="/etc/systemd/system/fenestra-sddm-random-bg.service"
BG_STATE="/var/lib/fenestra-sddm-random-bg.seen"

say()  { printf '%s\n' "$*"; }
ask()  { # ask "question" -> yes by default, no if the answer starts with n/N
  local a
  read -r -p "$1 [Y/n] " a || a=""
  case "$a" in [Nn]*) return 1 ;; *) return 0 ;; esac
}
ask_no() { # ask "question" -> no by default, yes only if the answer starts with y/Y
  local a
  read -r -p "$1 [y/N] " a || a=""
  case "$a" in [YyOo]*) return 0 ;; *) return 1 ;; esac
}

if [ "$(id -u)" -ne 0 ]; then
  say "Please run with sudo:  sudo bash install.sh"
  exit 1
fi

REAL_USER="${SUDO_USER:-}"
USER_HOME=""
PICTURES=""
if [ -n "$REAL_USER" ] && [ "$REAL_USER" != "root" ]; then
  USER_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
  PICTURES="$(sudo -u "$REAL_USER" HOME="$USER_HOME" xdg-user-dir PICTURES 2>/dev/null || true)"
  if [ -z "$PICTURES" ] || [ "$PICTURES" = "$USER_HOME" ]; then
    PICTURES="$USER_HOME/Pictures"
  fi
fi

# Folder names in the user's language (same 12 languages as the login screen)
lang="${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}"
lang="${lang%%.*}"; lang="${lang%%_*}"
case "$lang" in
  fr) W="Fonds";             D="Bureau";            L="Écran de connexion" ;;
  de) W="Hintergrundbilder"; D="Arbeitsfläche";     L="Anmeldebildschirm" ;;
  es) W="Fondos";            D="Escritorio";        L="Pantalla de inicio de sesión" ;;
  it) W="Sfondi";            D="Desktop";           L="Schermata di accesso" ;;
  pt) W="Planos de fundo";   D="Área de trabalho";  L="Tela de login" ;;
  nl) W="Achtergronden";     D="Bureaublad";        L="Aanmeldscherm" ;;
  pl) W="Tapety";            D="Pulpit";            L="Ekran logowania" ;;
  ru) W="Обои";              D="Рабочий стол";      L="Экран входа" ;;
  tr) W="Duvar kağıtları";   D="Masaüstü";          L="Giriş ekranı" ;;
  ja) W="壁紙";               D="デスクトップ";        L="ログイン画面" ;;
  zh) W="壁纸";               D="桌面";               L="登录屏幕" ;;
  *)  W="Wallpapers";        D="Desktop";           L="Login screen" ;;
esac

# ───────────────────────── Uninstall ─────────────────────────
if [ "${1:-}" = "--uninstall" ]; then
  say "Fenestra SDDM - uninstall"
  if [ -d "$DEST/Backgrounds" ]; then
    say "Warning: images you added to $DEST/Backgrounds will be deleted too."
    ask_no "Continue?" || { say "Cancelled, nothing removed."; exit 0; }
  fi
  if [ -f "$BG_SERVICE" ]; then
    systemctl disable fenestra-sddm-random-bg.service 2>/dev/null || true
    rm -f "$BG_SERVICE"
    systemctl daemon-reload
  fi
  rm -f "$BG_SCRIPT" "$BG_STATE" "$CONF_DEST"
  rm -rf "$DEST"
  if [ -n "$PICTURES" ] && [ -d "$PICTURES" ]; then
    # only the shortcut pointing to the theme is removed
    find "$PICTURES" -maxdepth 2 -type l -lname "$DEST/Backgrounds" -delete 2>/dev/null || true
  fi
  # If Fenestra was the selected login theme, set Breeze (standard Plasma theme) back.
  for f in /etc/sddm.conf /etc/sddm.conf.d/*.conf; do
    [ -f "$f" ] || continue
    if grep -q "^Current=$THEME_NAME[[:space:]]*$" "$f"; then
      if [ -d /usr/share/sddm/themes/breeze ]; then
        sed -i "s/^Current=$THEME_NAME[[:space:]]*$/Current=breeze/" "$f"
        say "  login screen theme set back to Breeze ($f)"
      else
        sed -i "/^Current=$THEME_NAME[[:space:]]*$/d" "$f"
        say "  Breeze not found: choose another login screen theme in System Settings"
      fi
    fi
  done
  say "Done."
  exit 0
fi

# ───────────────────────── Install ─────────────────────────
for f in "$SRC/Main.qml" "$SRC/metadata.desktop" "$CONF_SRC" "$BG_SCRIPT_SRC" "$BG_SERVICE_SRC"; do
  [ -e "$f" ] || { say "Missing file: $f (run install.sh from the downloaded folder)"; exit 1; }
done

say "Fenestra SDDM - install"

# 1. Theme (keeps the images you added to Backgrounds/ when updating)
keep=""
if [ -d "$DEST/Backgrounds" ]; then
  keep="$(mktemp -d)"
  find "$DEST/Backgrounds" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) \
       ! -name 'default.jpg' -exec cp -p {} "$keep/" \;
fi
rm -rf "$DEST"
cp -r "$SRC" "$DEST"
if [ -n "$keep" ]; then
  for f in "$keep"/*; do
    [ -e "$f" ] || continue
    [ -e "$DEST/Backgrounds/$(basename "$f")" ] || cp -p "$f" "$DEST/Backgrounds/"
  done
  rm -rf "$keep"
fi
chown -R root:root "$DEST"
find "$DEST" -type d -exec chmod 755 {} +
find "$DEST" -type f -exec chmod 644 {} +
say "  theme installed in $DEST"

# 2. Backgrounds/ writable by administrators
ADMIN_GROUP=""
for g in wheel sudo admin; do
  if getent group "$g" >/dev/null; then ADMIN_GROUP="$g"; break; fi
done
if [ -n "$ADMIN_GROUP" ]; then
  chgrp "$ADMIN_GROUP" "$DEST/Backgrounds"
  chmod 2775 "$DEST/Backgrounds"
  say "  Backgrounds/ writable by the '$ADMIN_GROUP' group"
else
  say "  no wheel/sudo group found: Backgrounds/ stays writable by root only"
fi

# 3. Virtual keyboard + network indicator on the Wayland greeter
mkdir -p /etc/sddm.conf.d
install -m 644 "$CONF_SRC" "$CONF_DEST"
say "  SDDM settings installed in $CONF_DEST"

# 4. Random background (optional)
if ask "Show a different background at every boot (random, without repetition)?"; then
  install -m 755 "$BG_SCRIPT_SRC" "$BG_SCRIPT"
  install -m 644 "$BG_SERVICE_SRC" "$BG_SERVICE"
  systemctl daemon-reload
  systemctl enable fenestra-sddm-random-bg.service >/dev/null 2>&1
  "$BG_SCRIPT" || true
  say "  random background enabled"
fi

# 5. Shortcuts in the Pictures folder of the user who ran sudo
if [ -n "$PICTURES" ]; then
  sudo -u "$REAL_USER" mkdir -p "$PICTURES/$W" "$USER_HOME/.local/share/wallpapers"
  for pair in "$L|$DEST/Backgrounds" "$D|$USER_HOME/.local/share/wallpapers"; do
    name="${pair%%|*}"; target="${pair#*|}"
    link="$PICTURES/$W/$name"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
      say "  $link already exists (not a shortcut), left unchanged"
    else
      sudo -u "$REAL_USER" ln -sfn "$target" "$link"
    fi
  done
  say "  shortcuts created in $PICTURES/$W"
fi

say ""
say "Done. Select \"Fenestra\" in System Settings > Colors & Themes > Login Screen (SDDM)."
say "Fenestra is made for SDDM on Wayland (KDE Plasma 6)."
