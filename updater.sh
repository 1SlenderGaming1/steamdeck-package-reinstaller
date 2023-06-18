#!/bin/bash

PARU=(
  'betterdiscordctl'
)
PACMAN=(
  'git' 
  'icoutils' # EXE icons in Dolphin
  'neofetch'
  'wine'
  'discord'
  # 'neovim' # AppImage version installed as of now
  # 'spotify'
)



dev_dir="/dev/" # append null or tty based on supress flag
n=""            # newline for output suppression

if [[ $1 == "-s" || $1 == "--supress" ]]; then
  echo "Supressing install output."
  dev_dir+="null"
else
  dev_dir+="tty"
  n="\n"
fi


sudo steamos-readonly disable
echo -e "Steamos readonly was disabled${n}"

echo -e "Updating base-devel${n}"
sudo pacman --noconfirm --overwrite \* --needed base-devel 1> dev_dir

echo -e "Checking for packages\n"

for pkg in "${PACMAN[@]}"; do
  if ! command -v "$pkg" &> $dev_dir; then
    sudo pacman --noconfirm --needed -S "$pkg"
  else 
    echo "$pkg already installed"  
  fi
done

for pkg in "${PARU[@]}"; do
  if ! command -v "$pkg" &> /dev/null; then
    paru --skipreview "$pkg" 
  else 
    echo "$pkg already installed"
  fi
done


echo "SpotX Adblock Patch"
spotx_installer() { bash <(curl -sSL "https://raw.githubusercontent.com/SpotX-CLI/SpotX-Linux/main/install.sh") -ce; }
SPOTIFY_INSTALLED=0

if ! flatpak info "com.spotify.Client" > /dev/null; then
  SPOTIFY_INSTALLED=1
  echo "Flatpak version found"
  spotx_installer -P "/var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/"
fi

if ! command -v spotify; then
  SPOTIFY_INSTALLED=1
  echo "CLI version found"
  spotx_installer
fi 

[ $SPOTIFY_INSTALLED -eq 1 ] || echo "Spotify not installed"


# clean up
paru -c 

# complete
notify-send -e -a "Image Update Setup" -u normal "Setup Complete" "Enjoy the pog."

