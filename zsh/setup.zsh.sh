#!/bin/bash

# =============================================================================
# Script d'installation et de configuration de Zsh avec Oh My Zsh et Powerlevel10k
# =============================================================================
# Ce script configure votre environnement Zsh en installant Oh My Zsh,
# Powerlevel10k, les plugins nécessaires, et les polices requises.
# =============================================================================

# ------------------------------
# 1. Détecter le système d'exploitation
# ------------------------------
OS="$(uname)"
case $OS in
  Linux*)
    OS_TYPE="Linux"
    ;;
  Darwin*)
    OS_TYPE="macOS"
    ;;
  *)
    echo "Système d'exploitation non supporté: $OS"
    exit 1
    ;;
esac
echo "Système détecté: $OS_TYPE"

# ------------------------------
# 2. Installer Homebrew (si sur macOS et non installé)
# ------------------------------
if [[ "$OS_TYPE" == "macOS" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew non trouvé. Installation de Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Ajout de Homebrew au PATH..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew est déjà installé."
  fi
fi

# ------------------------------
# 3. Installer les dépendances
# ------------------------------
echo "Installation des dépendances..."

# Installer Git (si non installé)
if ! command -v git >/dev/null 2>&1; then
  echo "Git non trouvé. Installation de Git..."
  if [[ "$OS_TYPE" == "macOS" ]]; then
    brew install git
  else
    sudo apt update
    sudo apt install -y git
  fi
else
  echo "Git est déjà installé."
fi

# Installer curl (si non installé)
if ! command -v curl >/dev/null 2>&1; then
  echo "curl non trouvé. Installation de curl..."
  if [[ "$OS_TYPE" == "macOS" ]]; then
    brew install curl
  else
    sudo apt update
    sudo apt install -y curl
  fi
else
  echo "curl est déjà installé."
fi

# Installer wget (si non installé et nécessaire)
if ! command -v wget >/dev/null 2>&1; then
  echo "wget non trouvé. Installation de wget..."
  if [[ "$OS_TYPE" == "macOS" ]]; then
    brew install wget
  else
    sudo apt update
    sudo apt install -y wget
  fi
else
  echo "wget est déjà installé."
fi

# Installer Oh My Zsh (si non installé)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh non trouvé. Installation d'Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh est déjà installé."
fi

# ------------------------------
# 4. Installer Powerlevel10k
# ------------------------------
echo "Installation de Powerlevel10k..."

if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
  git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  echo "Powerlevel10k installé."
else
  echo "Powerlevel10k est déjà installé."
fi

# ------------------------------
# 5. Installer les plugins Zsh
# ------------------------------
echo "Installation des plugins Zsh..."

# Définir le répertoire des plugins personnalisés
CUSTOM_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# Liste des plugins à installer
declare -a plugins_to_install=(
  "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
  "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
  "common-aliases https://github.com/extrawurst/zsh-common-aliases.git"
  "extract https://github.com/zsh-users/zsh-extract.git"
)

# Cloner chaque plugin
for plugin in "${plugins_to_install[@]}"; do
  IFS=' ' read -r plugin_name repo_url <<< "$plugin"
  if [[ ! -d "$CUSTOM_PLUGINS_DIR/$plugin_name" ]]; then
    git clone "$repo_url" "$CUSTOM_PLUGINS_DIR/$plugin_name"
    echo "Plugin $plugin_name installé."
  else
    echo "Plugin $plugin_name est déjà installé."
  fi
done

# ------------------------------
# 6. Installer les polices MesloLGS NF
# ------------------------------
echo "Installation des polices MesloLGS NF..."

install_fonts_mac() {
  brew tap homebrew/cask-fonts
  brew install --cask font-meslo-lg-nerd-font
}

install_fonts_linux() {
  FONTS_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONTS_DIR"
  echo "Téléchargement des polices MesloLGS NF..."
  wget -qO- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf | tee "$FONTS_DIR/MesloLGS NF Regular.ttf" >/dev/null
  wget -qO- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf | tee "$FONTS_DIR/MesloLGS NF Bold.ttf" >/dev/null
  wget -qO- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf | tee "$FONTS_DIR/MesloLGS NF Italic.ttf" >/dev/null
  wget -qO- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf | tee "$FONTS_DIR/MesloLGS NF Bold Italic.ttf" >/dev/null
  fc-cache -fv "$FONTS_DIR"
  echo "Polices MesloLGS NF installées."
}

if [[ "$OS_TYPE" == "macOS" ]]; then
  install_fonts_mac
elif [[ "$OS_TYPE" == "Linux" ]]; then
  install_fonts_linux
fi

# ------------------------------
# 7. Copier le fichier .zshrc
# ------------------------------
echo "Configuration de .zshrc..."

# Définir le chemin vers le fichier .zshrc
# Assurez-vous que ce script est exécuté depuis le répertoire où se trouve le .zshrc fourni
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_SOURCE="$SCRIPT_DIR/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"

# Sauvegarder l'ancien .zshrc s'il existe
if [[ -f "$ZSHRC_TARGET" ]]; then
  echo "Sauvegarde de l'ancien .zshrc en .zshrc.backup..."
  cp "$ZSHRC_TARGET" "$ZSHRC_TARGET.backup"
fi

# Copier le nouveau .zshrc
cp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
echo ".zshrc copié."

# ------------------------------
# 8. Installer Volta (gestionnaire de versions Node.js)
# ------------------------------
echo "Installation de Volta..."

if [[ ! -d "$HOME/.volta" ]]; then
  curl https://get.volta.sh | bash
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
  echo "Volta installé."
else
  echo "Volta est déjà installé."
fi

# ------------------------------
# 9. Installer les polices si nécessaire (instruction pour l'utilisateur)
# ------------------------------
if [[ "$OS_TYPE" == "macOS" ]]; then
  echo "Assurez-vous que votre terminal utilise la police MesloLGS NF."
elif [[ "$OS_TYPE" == "Linux" ]]; then
  echo "Les polices MesloLGS NF ont été installées dans $HOME/.local/share/fonts."
  echo "Assurez-vous que votre terminal utilise la police MesloLGS NF."
fi

# ------------------------------
# 10. Recharger Zsh
# ------------------------------
echo "Rechargement de la configuration Zsh..."
source "$ZSHRC_TARGET"

# ------------------------------
# 11. Finalisation
# ------------------------------
echo "Installation et configuration terminées."
echo "Si Powerlevel10k ne s'affiche pas correctement, assurez-vous que votre terminal utilise la police MesloLGS NF."
echo "Vous pouvez également lancer la configuration de Powerlevel10k manuellement avec : p10k configure"

# Optionnel : Lancer l'assistant de configuration de Powerlevel10k
# Uncomment the following line if you want to start the configuration automatically
# p10k configure